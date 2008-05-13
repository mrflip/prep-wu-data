#!/usr/bin/env python 
# -*- coding: utf-8 -*-
import  re
import  os, sys, os.path 
import  csv, yaml
import  xlrd

OUT_MAIN_DIR         = os.environ['HOME']+ '/ics/data/fixd/demographics/us/statisticalabstract/'
IN_TABLES_DIR        = os.environ['HOME']+ '/ics/data/rawd/demographics/us/statisticalabstract/xls/statab/2008/tables'
IN_TEMPLATE_SCHEMA   = os.environ['HOME']+'/ics/code/munge/demographics/us/statisticalabstract/statistical_abstract_table.icss.yaml'
COLLECTION_UNIQID = 'Statistical Abstract'
COLLECTION_SHORTEST  = 'statab'
UNIQID_TITLECHARS = 35

#
# Takes a statistical abstract file, sucks what it can out,
# and orchestrates writing it in each useful format.
#
def parse_statab(infilename):
    # load template
    stream = file(IN_TEMPLATE_SCHEMA, 'r')
    statab = yaml.safe_load(stream)

    # load data
    statab['infochimps_rawdata'] = xlrd_xls2array(infilename)
    if not statab['infochimps_rawdata']: return
    
    # pull info from filename into schema
    statab['infochimps_schema']['notes']['_filename'] = infilename
    re_filename = re.compile(r'statab/(\d{4})/.*/\d\ds(\d{4})\.xls')
    filename_match = re_filename.search(infilename)
    statab['infochimps_schema']['notes']['_year']     = filename_match.group(1) if filename_match else ''
    statab['infochimps_schema']['notes']['tablenum'] = filename_match.group(2) if filename_match else ''
    statab['infochimps_schema']['collection'] = "%s %s" % \
        (statab['infochimps_schema']['collection'], statab['infochimps_schema']['notes']['_year'])

    # pull info from data itself into schema
    statab = grok_statab(statab)
    describe_dataset(statab)

    # kill off some admin fields

    # Export schema file, correspondingly named
    (outdir, outfilebase) = statab_save_makedirs(statab, infilename)
    statab['infochimps_schema']['formats'] = {'xls': {}, 'yaml': {}, 'csv': {}}
    statab_save_schema(statab, outdir, outfilebase)
    statab_save_yaml  (statab, outdir, outfilebase)
    statab_save_xls   (statab, outdir, outfilebase, infilename)
    statab_save_csv   (statab, outdir, outfilebase)
    
    return statab

#
# Import the XLS files
#

def tupledate_to_isodate(tupledate):
    """
    Turns a gregorian (year, month, day, hour, minute, nearest_second) into a
    standard YYYY-MM-DDTHH:MM:SS ISO date.  If the date part is all zeros, it's
    assumed to be a time; if the time part is all zeros it's assumed to be a date;
    if all of it is zeros it's taken to be a time, specifically 00:00:00 (midnight).

    Note that datetimes of midnight will come back as date-only strings.  A date
    of month=0 and day=0 is meaningless, so that part of the coercion is safe.
    For more on the hairy nature of Excel date/times see http://www.lexicon.net/sjmachin/xlrd.html
    """
    (y,m,d, hh,mm,ss) = tupledate
    nonzero = lambda n: n!=0
    date = "%04d-%02d-%02d"  % (y,m,d)    if filter(nonzero, (y,m,d))                else ''
    time = "T%02d:%02d:%02d" % (hh,mm,ss) if filter(nonzero, (hh,mm,ss)) or not date else ''
    return date+time

#
#   
# http://aspn.activestate.com/ASPN/Cookbook/Python/Recipe/483742
#
def format_excelval(book, type, value, wanttupledate):
    """ Clean up the incoming excel data """
    ##  Data Type Codes:
    ##  EMPTY   0
    ##  TEXT    1 a Unicode string 
    ##  NUMBER  2 float 
    ##  DATE    3 float 
    ##  BOOLEAN 4 int; 1 means TRUE, 0 means FALSE 
    ##  ERROR   5 
    returnrow = []
    if   type == 2: # TEXT
        if value == int(value): value = int(value)
    elif type == 3: # NUMBER
        datetuple = xlrd.xldate_as_tuple(value, book.datemode)
        value = datetuple if wanttupledate else tupledate_to_isodate(datetuple)
    elif type == 5: # ERROR
        value = xlrd.error_text_from_code[value]
    return value

def xlrd_xls2array(infilename):
    """ Returns a list of sheets; each sheet is a dict containing
    * sheet_name: unicode string naming that sheet
    * sheet_data: 2-D table holding the converted cells of that sheet
    """    
    try:    book = xlrd.open_workbook(infilename)
    except: return pyxltr_xls2array(infilename) # see if that has better luck
    
    sheets     = []
    formatter  = lambda(t,v): format_excelval(book,t,v,False)
    
    for sheet_name in book.sheet_names():
        raw_sheet = book.sheet_by_name(sheet_name)
        data      = []
        for row in range(raw_sheet.nrows):
            (types, values) = (raw_sheet.row_types(row), raw_sheet.row_values(row))
            data.append(map(formatter, zip(types, values)))
        sheets.append({ 'sheet_name': sheet_name, 'sheet_data': data })
    return sheets


# The pyExcelerator module doesn't work as well -- dates and unicode are problems
# 
# The pyExcelerator (pyxltr_xls2array) portions of this code taken from the
# BSD-licensed tools/ directory and Copyright (C) 2005 Kiseliov Roman and Gerry
# from the pyExcelerator project:
#   http://sourceforge.net/projects/pyexcelerator
# License for this portion of code follows same BSDish license
#
def pyxltr_xls2array(infilename):
    """
    get an array (one per excel sheet) of 2-d arrays holding the cells in that sheet
    """
    import pyExcelerator
    # open file
    try:     raw_sheets = pyExcelerator.parse_xls(infilename, 'cp1251')
    except:  print >>sys.stderr, "Can't read excel file %s" % (infilename) ; return []
    # pull out cell data
    excel_sheets = []
    for sheet_name, values in raw_sheets:
        if not values.keys(): continue
        # Column and row names
        (nrows, ncols) = map(max, zip(*values.keys()))
        # turn that sheet into list of lists
        excel_sheets.append({
            'sheet_name':       sheet_name,
            'sheet_data':       [ ([values.get((row, col), None) for col in range(0,ncols+1)])
                                 for row in range(0,nrows+1) ]
            })
    return excel_sheets


#
# Pull metadata from the statistical abstract files
#
def grok_statab(statab):
    """
    Pull out what we can from the statistical abstract files.
    For all of these, we accept any matching token in the first non-empty
    cell; that token is killed off before the remaining line is examined
    (some of the files have pertinent crap on the same line as its token,
    though most don't.)
    
    Within the multiline fields, each non-empty cell becomes its own line; a
    row of completely empty cells becomes a blank line.

    ^HEADNOTES?
    go until blank line.

    ^FOOTNOTES? -- footnotes go from the cell "FOOTNOTE[S]" until the next thingy.
    Each is introduced by a "\1" backslash then a number.
       FOOTNOTES,,,,,,,,
       \1 A person is counted in each area visited but only once in the total.,,,,,,,,
       \2 2005 U.S. Outbound totals are preliminary estimates.,,,,,,,,
    We'll turn this into a textile # list.


    ^SYMBOLS? -- symbols go from the cell "SYMBOL[S]" until the next thingy.
    Each looks like
      "Z Less than 500 or .05 percent"
    We'll turn this into a textile * list with the symbol in __italics__

    ^Source:  -- sources go from a cell "Source: ..." until the next thingy.
    There may be one or more INTERNET LINK(S), as well as one or more
    <http://urls.in.angle.brackets>.
    * The rest of the Source: line is taken as the title.
    * The first INTERNET LINK is taken as the URL for that source.
    * No attempt is make to identify a citation.
    * The whole thing (these features included) goes into the notes.

       "Source: U.S. Bureau of Labor Statistics, Bulletin 2307; <mdit>News, <med>USDL",,,,,,,,,,
       "06-514, March 24, 2006; and unpublished data. See Internet site",,,,,,,,,,
       <http://www.bls.gov/news.release/hsgec.toc.htm>.,,,,,,,,,,
       ,,,,,,,,,,
       INTERNET LINK,,,,,,,,,,
       http://www.bls.gov/news.release/hsgec.toc.htm,,,,,,,,,,

    or

       "Source: Physicians: American Medical Association, Chicago, IL,",,,,
       "Physician Characteristics and Distribution in the U.S., annual  ",,,,
       (copyright); Nurses: U.S. Dept. of Health and Human ,,,,
       "Services, Health Resources and Services Administration, unpublished ",,,,
       data. ,,,,
       ,,,,
       INTERNET LINKS,,,,
       http://www.bhpr.hrsa.gov/,,,,
       http://www.ama-assn.org/,,,,

    table data marked off by '!!infochimp_table_data',
    '!!infochimp_table_fields' (optional) and '!!infochimp_table_end'.

    Only one table per file.

    Metadata and cruft before or after the table is OK. The first line of the
    table_data must be a header row; all following are taken as a 2-D array of
    values.
    
    """

    schema = statab['infochimps_schema']
    sheets  = statab['infochimps_rawdata']

    re_title         = re.compile(r'^Table\s+([\w\-]+)\.\s+(.*)');
    re_headnote_head = re.compile(r'^HEADNOTES?');
    re_footnote_head = re.compile(r'^FOOTNOTES?');
    re_footnote      = re.compile(r'\\(\d+)\s+(.*)');
    re_symbol_head   = re.compile(r'^SYMBOLS?');
    re_symbol        = re.compile(r'(\w+)\s+(.*)');
    re_source_head   = re.compile(r'^Source:\s*');
    re_table_data    = re.compile(r'^!!infochimp_table_data');
    re_table_fields  = re.compile(r'^!!infochimp_table_fields');
    re_table_end     = re.compile(r'^!!infochimp_table_end');   

    name        = ''
    headnotes   = []
    footnotes   = {}
    symbols     = {}
    sources     = {}
    parsed_data = []
    field_names = []
    field_info  = []
    
    for (sheet_idx, sheet) in enumerate(sheets):
        phase = None
        for row in sheet['sheet_data']:
            # get first non-blank cell
            firstcell = None
            for cell in map(clean_xls, row):
                if (cell): firstcell = cell; break
            if not firstcell: continue  # phase = None; continue
            
            # Look for title
            titlematch = re_title.search(firstcell) if (firstcell and not name) else None
            if titlematch:
                (title_tablenum, tablename) = titlematch.groups()
                tablenum = schema['notes']['tablenum']
                # the table num in the title is unreliable
                if (int(title_tablenum) != int(tablenum)):
                    schema['notes']['tablenum'] = "%s (or maybe %s)" % (tablenum, title_tablenum)
                # stuff in name, ids
                name                  = "%s (%s %s Table %s)" % \
                    (tablename, COLLECTION_UNIQID, schema['notes']['_year'], tablenum)
                schema['coll_uniqid'] = "%s_%s" % (
                    camelize(COLLECTION_UNIQID), schema['notes']['_year'])
                schema['uniqid']      = "%s%s_%04d_%s" % (
                    COLLECTION_SHORTEST, schema['notes']['_year'],
                    int(tablenum), camelize(tablename)[0:UNIQID_TITLECHARS])
                fix_schema_tags(schema, tablename)
                continue
            if not name:
                filename = os.path.split(schema['notes']['_filename'])[1]
                name                 = filename
                schema['uniqid']     = filename
                print >>sys.stderr, "Fucked up filename %s" % (filename,)
                
            
            if   re_headnote_head.search(firstcell):
                phase = 'headnotes'
                headnotes.append( [] )
            elif re_footnote_head.search(firstcell):
                phase = 'footnotes'
                footnotes[sheet_idx] = []
                footnote_key = 0
            elif re_symbol_head.search(firstcell):
                phase = 'symbols'
                symbols  [sheet_idx] = []
            elif re_source_head.search(firstcell):
                phase = 'sources'
                sources  [sheet_idx] = sources.get(sheet_idx, [])
                sources  [sheet_idx].append( [] )
            elif re_table_data.search(firstcell):
                phase = 'table_data'; continue
            elif re_table_fields.search(firstcell):
                phase = 'table_fields'; continue
            elif re_table_end.search(firstcell):
                phase = ''; continue

            if (phase == 'table_data'):
                if not field_names:    # first row is field names
                    field_names = map( lambda c: re.sub(r'\s*\\\d+','',c), row )
                else:                  # all following are data
                    parsed_data.append(row)

            if (phase == 'table_fields'):
                field_info.append(row)

            if (phase == 'headnotes'):
                for ocell in row:
                    # skip blank line or headnotes header
                    cell = clean_xls(ocell)
                    if ((not cell) or (re_headnote_head.search(cell))): continue
                    # Dump into most recent headnote slot
                    headnotes[-1].append(cell)

            if (phase == 'footnotes'):
                for ocell in row:
                    # skip blank line or FOOTNOTES header
                    cell = clean_xls(ocell)
                    if ((not cell) or (re_footnote_head.search(cell))): continue
                    # ok, take footnote
                    footnote_match = re_footnote.search(cell)
                    if footnote_match:
                        # start of a new footnote index
                        footnote_key = int(footnote_match.group(1))-1
                        saften_list(footnotes[sheet_idx], footnote_key)
                        footnotes[sheet_idx][footnote_key] = [ footnote_match.group(2) ]
                    else:
                        # push onto currently running footnote
                        saften_list(footnotes[sheet_idx], footnote_key)
                        footnotes[sheet_idx][footnote_key].append(cell)

            if (phase == 'symbols'):
                for ocell in row:
                    # skip blank line or symbols header
                    cell = clean_xls(ocell)
                    re_source_head.sub
                    if ((not cell) or (re_symbol_head.search(cell))): continue
                    # push sheet, symbol and definition onto symbols stack
                    symbol_match = re_symbol.search(cell)
                    if symbol_match:
                        symbols[sheet_idx].append( ["(%s) %s" % symbol_match.groups()] )

            if (phase == 'sources'):
                for ocell in row:
                    # skip blank line or sources header
                    cell = clean_xls(ocell)
                    cell = re_source_head.sub('', cell) # kill off "Source: " if any
                    if (not cell): continue
                    # Dump into most recent source slot
                    sources[sheet_idx][-1].append(cell)

    # stuff results into schema
    schema['name'] = name
    if headnotes: schema['notes']['headnotes'] = "\n".join(sum(headnotes,[]))              
    if footnotes: schema['notes']['footnotes'] = textilize_list_by_sheets(sheets, footnotes)    
    if symbols:   schema['notes']['symbols']   = textilize_list_by_sheets(sheets, symbols, '*')     
    #if sources:  schema['notes']['sources']   = textilize_list_by_sheets(sheets, sources)
    stuff_sources(schema, sheets, sources)

    if parsed_data:
        field_uniqids = uniqify(map( camelize, field_names ))
        schema_fields_elements = ('name', 'uniqid', 'units', 'datatype', 'tags')
        schema['fields'] = [ dict(zip(schema_fields_elements, vals))
                             for vals in zip(*([field_names, field_uniqids] + field_info)) ]
        statab['infochimps_data'] = parsed_data
        
    # and merge back in with data.
    statab['infochimps_schema'] = schema
    
    return statab

def stuff_sources(schema, sheets, sources):
    """
    Try to identify what's identifiable from the lines in a stat.ab. source citation
    and stuff it into a schema "contributor"
    """
    re_moreinfo     = re.compile(r'For more information:', re.I)
    re_internetlink = re.compile(r'INTERNET LINK')
    re_url          = re.compile(r'((?:https?|ftp)://[^/]+\.[^/]{2,4}/?\S*)')
    for (sheet_idx, alist) in sources.items():
        sheet_ref = "\n\n__referenced on dataset section %s (#%s)__" % (sheets[sheet_idx]['sheet_name'], sheet_idx+1)
        for source in alist:
            contrib = {}
            contrib['name'] = source[0]
            contrib['desc'] = "\n\n".join(source) + sheet_ref

            # Hunt for a URL in the source
            url = None
            for (idx, line) in enumerate(source):
                url_match = re_url.search(line)
                if url_match: url = url_match.group(1)
                # however, prefer the link following a line that says INTERNET LINK or "For more information:"
                if (idx+1<len(source)) and (re_internetlink.search(line) or re_moreinfo.search(line)):
                    url_match = re_url.search(source[idx+1])
                    if url_match: url = url_match.group(1); break
            if url: contrib['url'] = url
            
            # bank the contrib
            schema['contributors'].append(contrib)

def describe_dataset(statab):
    """
    """
    schema = statab['infochimps_schema']
    if statab.get('infochimps_data'):
        data = [[ f['name'] for f in schema['fields'] ]] + statab['infochimps_data']
    else:
        data = statab['infochimps_rawdata'][0]['sheet_data'][6:]

    (rows, cols) = (len(data), len(data[0]) if len(data)>0 else 0)
    schema['notes']['shape'] = 'table: [%d, %d]' % (rows, cols)
    schema['notes']['snippet'] = snippetize(data, 12, 2, 8000)
  
    # and merge back in with data.
    statab['infochimps_schema'] = schema

def fix_schema_tags(schema, fodder):
    """Try to get what we can from the title"""
    tags =  schema['tags']
    tags += ' ' + fodder
    tags = tags.lower()
    # make 10,000 into 10000
    tags = re.sub(r'\b(\d+),(\d+)\b', lambda m: (m.group(1)+m.group(2)), tags)
    tags = re.sub(r'\W+', ' ', tags)
    # kill off years
    tags = re.sub(r'\b(\d{4})\b', '', tags)
    # stopwords
    tags = re.sub(r' +(\w|and|I|a|about|an|are|as|at|be|by|com|de|en|for|from|how|in|is|it|la|of|on|or|that|the|this|to|was|what|when|where|who|will|with|the)\b',
                       " ", tags)
    schema['tags'] = tags


#
# Slightly more generic crap
#

def clean_xls(s):
    """Kill off cruft and do minimal escaping.   Only metadata is treated with this function
    """
    clean = unicode(s or '')
    # There's some weird juju with cells that have extra "\\n" (not a newline, an encoded \\n)
    # and others that have a $del but I think those are actually corrupted files
    # clean = re.sub(r'(?:\$del|\\n)', '  ', clean)
    chars = ( ('&','&amp;'), ('<','&lt; '), ('>',' &gt;') )
    for (c, esc) in chars:
        clean = re.sub(c, esc, clean)
    return clean.strip()

        
def camelize(s):
    h = unicode(s)
    h = re.sub(r'(?:[_\s]+)([a-z])',
               lambda m: m.group(1).upper(), h)
    h = re.sub(r'[\-\.]+', '_', h)
    h = re.sub(r'\W',      '',  h)
    return h

def uniqify(l):
    """
    Takes a sequence of strings and generates a unique list of strings:
    each n'th occurence of a string after the first gets _(n-1) appended.

    >>> uniqify(['a', 'b', 'a', 'c', 'b', 'a', 'a'])
    ['a', 'b', 'a_1', 'c', 'b_1', 'a_2', 'a_3']
    """
    u    = []
    seen = {}
    for el in l:
        seen[el] = seen[el]+1 if seen.get(el) else 1
        u.append(
            el+'_'+str(seen[el]-1) if (seen[el]!=1) else el )
    return u

def utf8ize(l):
    """Make string-like things into utf-8, leave other things alone
    """
    return [unicode(s).encode("utf-8") if hasattr(s,'encode') else s for s in l]

def saften_list(l, i):
    """If list item i doesn't exist, extend l so that it has an item i
    """
    l += [ [] ]*(1+i-len(l))
    if not l[i]: l[i] = []
    return l

def textilize_list_by_sheets(sheets, list_by_sheets, bullet='#'):
    """
    Sheet titles become headings;
    items become numbered lists;
    runs of text become indented blocks"""
    text = ''
    for (sheet_idx, alist) in list_by_sheets.items():
        text += "h2. %s (pg %s)\n\n" % (sheets[sheet_idx]['sheet_name'], sheet_idx+1)
        text += textilize_list(alist, bullet)
        text += "\n\n"
    return text

def textilize_list(alist, bullet='#'):
    """
    runs of text become indented blocks.
    Use bullet='#' for numbered, '*' for bulleted
    """
    text = ''
    for li in alist:
        text += "%s %s\n" % (bullet, "\n  ".join(li))
    return text

def textilize_table(table):
    """Turns a 2-d table into a textile table
    """
    def blank_or_str(s): return '-' if s is None else unicode(s)
    return "\n".join( [('| '+ " | ".join(map(blank_or_str, row)) +' |') for row in table] )

def snippetize(table, head=6, tail=2, maxlen = 8000):
    """
    Pull a representative snippet, turn into a textile table
      http://hobix.com/textile/#tables

      Note: table row specifiers must be in the form #SPAN#ALIGN#CSS
    """
    # figure out slice to take
    (rows, cols) = (len(table), len(table[0]))
    tail = -min(tail, rows-head);
    if tail >= 0: tail = None 
    snip_str = ("\n|\%d=. ... __snip__ ... |\n" % cols)
    # take some from the top, some from the end, stuff ellipsis in the middle
    snippet = textilize_table(table[0:head]) + \
              snip_str + \
              textilize_table(table[tail:]) + \
              "\n"
    # don't vomit too much out
    if len(snippet) > maxlen:
        snippet = snippet[0:maxlen-len(snip_str)] + snip_str
    return snippet              


def statab_save_makedirs(statab, infilename):
    # KLUDGE - depends on having the right directory structure
    tablenum_match = re.search(r'(\w+)/\d{4}/.*/\d\ds(\d\d)\d+\.', infilename)
    
    outfilebase = statab['infochimps_schema']['uniqid']
    outdir = os.path.join(OUT_MAIN_DIR)
    print "Writing to %s: %s" % (outdir, outfilebase)
    os.system('mkdir -p '+outdir)
    return (outdir, outfilebase)

def statab_save_schema(statab, outdir, outfilebase):
    stream = file(os.path.join(outdir, outfilebase+'.icss.yaml'), 'wb')
    schema_obj = [ { 'infochimps_schema': statab['infochimps_schema'] } ]
    yaml.safe_dump(schema_obj, stream, allow_unicode=True)
    stream.close()

def statab_save_yaml(statab, outdir, outfilebase):
    # Make dir for dataset
    fmtdir = os.path.join(outdir, outfilebase+'-yaml')
    os.system('mkdir -p '+ fmtdir)
    # copy in schema
    statab_save_schema(statab, fmtdir, outfilebase)
    # Save files
    stream = file(os.path.join(fmtdir, outfilebase+'.yaml'), 'wb')
    yaml.safe_dump(statab, stream, allow_unicode=True) #, default_flow_style=False, default_style=''
    stream.close()
    
def statab_save_xls(statab, outdir, outfilebase, xlsfilename):
    # Make dir for dataset
    fmtdir = os.path.join(outdir, outfilebase+'-xls')
    os.system('mkdir -p '+ fmtdir)
    # copy in schema
    statab_save_schema(statab, fmtdir, outfilebase)
    # Save files
    outfilename = os.path.join(fmtdir, outfilebase+'.xls')
    os.system('cp "%s" "%s"' % (xlsfilename, outfilename))

def dump_csv(table, outdir, outfilename):
    stream = file(os.path.join(outdir, outfilename), 'wb')
    # delimiter:        A one-character string used to separate fields. It defaults to ','. 
    # doublequote:      Controls how instances of quotechar appearing inside a field should be themselves be quoted. When True, the character is doubled. When False, the escapechar is used as a prefix to the quotechar. It defaults to True.  On output, if doublequote is False and no escapechar is set, Error is raised if a quotechar is found in a field. 
    # escapechar:       A one-character string used by the writer to escape the delimiter if quoting is set to QUOTE_NONE and the quotechar if doublequote is False. On reading, the escapechar removes any special meaning from the following character. It defaults to None, which disables escaping. 
    # lineterminator:   The string used to terminate lines produced by the writer. It defaults to '\r\n'. Note: The reader is hard-coded to recognise either '\r' or '\n' as end-of-line, and ignores lineterminator. This behavior may change in the future. 
    # quotechar:        A one-character string used to quote fields containing special characters, such as the delimiter or quotechar, or which contain new-line characters. It defaults to '"'. 
    # quoting:          Controls when quotes should be generated by the writer and recognised by the reader. It can take on any of the QUOTE_* constants (see section 9.1.1) and defaults to QUOTE_MINIMAL. 
    csvout = csv.writer(stream, delimiter=',', doublequote=False, escapechar='\\')
    csvout.writerows( map(utf8ize, table) )
    stream.close()

def statab_save_csv(statab, outdir, outfilebase):
    # Make dir for dataset
    fmtdir = os.path.join(outdir, outfilebase+'-csv')
    os.system('mkdir -p '+ fmtdir)
    # copy in schema
    statab_save_schema(statab, fmtdir, outfilebase)
    # Save files
    if statab.get('infochimps_data'):
        # headers plus data
        table = [[ f['name'] for f in statab['infochimps_schema']['fields'] ]] + \
                statab['infochimps_data']
        dump_csv(table, fmtdir, outfilebase+'.csv')
    for (sheet_idx, sheet) in enumerate(statab['infochimps_rawdata']):
        outfilename = "%s_%d_%s.csv" % (outfilebase, sheet_idx, camelize(sheet['sheet_name']))
        dump_csv(sheet['sheet_data'], fmtdir, outfilename)


#
# Main
#

# Handle each file given on command line, else do current directory.
try:    args = sys.argv[1:]
except: args = []
if len(args) < 1:
    infilenames = os.listdir(IN_TABLES_DIR)
    infilenames.sort()
    for infilename in infilenames:
        parts = infilename.split(".")
        if parts[-1] != "xls": continue
        parse_statab(os.path.join(IN_TABLES_DIR, infilename))
    sys.exit()
else:
    for arg in args:
        parse_statab(arg)
