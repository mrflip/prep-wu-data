#!/usr/bin/env ruby
$:.unshift ENV['HOME']+'/ics/code/lib/ruby/lib' # find infinite monkeywrench lib
require 'imw.rb'
require 'yaml'

FIELDS_W_ID = %w{prop type template sub_tpl}
FIELDS      = %w{name val join} + FIELDS_W_ID
INFOBOXEN_LINE = %r{
    <http://(
         dbpedia.org/resource            |
         upload.wikimedia.org/wikipedia  )  # name_head
    /([^>]+)>\s                             # name
    
    <http://(
         dbpedia.org/property            |
         purl.org/dc/terms               )  # prop_head
    /([^>]+)>\s                             # prop
    
    (        ".*"                        |
         <http://[^>]+                   )  # val
    (>|@\w\w|\^\^<.+>)                      # type
    
    \s\.
  }soix

RIDICULOUS_HEADS = %r!(List_of_asteroids)/(\d+)(?:%E2%80%93|-)(\d+)(?:/(.+))?\Z!o

#
# Take the dbpedia NT triples dump and emit 
# * pivoted templates
# * files suitable for loading into mysql.
#
def process_infoboxen_rdf3s(in_filename, dumproot = nil)
  # dumping ground for each field
  base_filename = File.basename(in_filename, '.nt')
  dumproot ||= './rawd/dump/'+base_filename
  obj_dump_files  = {}
  obj_dump_dir    = dumproot+"/#{base_filename}_objs" 
  mkdir_p           obj_dump_dir
  dump_files      = Hash.zip(FIELDS, 
                             FIELDS.map{     |field| open_dump_file(dumproot, base_filename, field, 'tsv')})
  dump_files.merge! Hash.zip(FIELDS_W_ID.map{|field| field+'_yaml'}, 
                             FIELDS_W_ID.map{|field| open_dump_file(dumproot, base_filename, field, 'yaml')})
  
  # lay in variables
  ids       = Hash.zip(FIELDS_W_ID, [{ }, { }, { }, { }])
  val_id    = 1; name_id = 1
  name      = ''; last_name  = nil; orig_name = nil
  obj       = [] # push all the values, to later spool out into tree. 
                 # (Template announcements, annoyingly, happen at __end__ of run).
  
  # process input file
  File.open(in_filename) do |in_file|
    in_file.each_line do |line|

      # -----------------------------------------------------------------------
      #
      # Extract info from line
      #
      matches = INFOBOXEN_LINE.match(line)
      if matches.nil? then warn "Funky line #{line}"; next; end
      name_head, name, prop_head, prop, val, type = matches.captures
      orig_name = name; name = unescape_7bit(name)
      sub_tpl  = ''

      # -----------------------------------------------------------------------
      #
      # Classify stuff
      #
      
      # objects
      if (name_head == "dbpedia.org/resource")
        # KLUDGE -- it chokes on the ~1M line 'list of asteroids'
        # so we'll trick lines like 
        #      List_of_asteroids/146801%E2%80%93146900 <-- that's 146801-146901 
        #   or List_of_asteroids/146801-146901
        # into becoming
        #      [[List_of_asteroids_146801-146900]]
        if    (name_match = RIDICULOUS_HEADS.match(name))
          name    = "%s_%s-%s" % name_match[1..3]
          sub_tpl = name_match[4] || ''
          val.gsub!(RIDICULOUS_HEADS, "%s_%s-%s%s" % [$1,$2,$3,($4 ? "/#{$4}" : "")])
          # $stderr.puts "Entering asteroid field %s (/%s): %s" % [name, sub_tpl, val] if name != last_name
        elsif (name_match = %r!\A([^/]+)/(.+)\Z!o.match(name)) 
          # normal foo/bar resources
          name, sub_tpl = name_match.captures() 
        end
      else
        # image rights lines
        warn "image resources are usually rights lines: '#{name_head}', '#{prop_head}'" if (prop_head != "purl.org/dc/terms")
        next
      end
      if (prop_head != "dbpedia.org/property")
        warn "image resources are usually rights lines: '#{name_head}', '#{prop_head}'"
        next
      end
      
      # values, templates
      template = "";    # have we found out what template we were working on?    
      if    ((val_match = %r!<http://dbpedia.org/resource/Template:(.*)!o.match(val)) && (prop == "wikiPageUsesTemplate"))
        # Template
        template =  unescape_7bit($1)
        val      = template # "{{Template:#{template}}}"
        type     = "WP:Template"
      elsif (val_match = %r!<http://dbpedia.org/resource/(.*)!o.match(val)) 
        val = "[[%s]]" % unescape_7bit($1)
        type = "link_wp"
        warn("Template links are usually wikiPageUsesTemplate: '#{line}") if
          (%r!<http://dbpedia.org/resource/Template:(.*)!o.match(val));
      elsif ((val_match = %r!<((?:ftp|https?)://.*)!o.match(val)) && (type == ">"))
        val = $1
        type = "link_ext"
      elsif (type == ">") 
        warn("dbpedia links are usually urls or sp links: #{line}")
      elsif (val =~ %r!\A"(.*)"\Z!o)
        val = $1;
      else
        warn("non-link values are ususally in quotes: '#{val}' (#{line})")
      end

      # -----------------------------------------------------------------------
      #
      # Assign IDs
      #
      FIELDS_W_ID.zip([prop, type, sub_tpl, template]).each do |k, v|
        ids[k][v] = 1 + ids[k].length unless ids[k].has_key?(v)
      end
      
      # -----------------------------------------------------------------------
      #
      # Emit objects immediately at meeting a new one
      #
      if ((last_name.nil?) || (name != last_name))
        # emit the previous obj 
        emit_obj(last_name, obj, obj_dump_dir, obj_dump_files) unless !last_name
        # emit the new name + its ID
        dump_files['name']   << "%d\t%s\t%s\n" % [ name_id, name, orig_name ]
        # wipe slate
        last_name = name
        obj      = []
        name_id  += 1
      end
      
      # -----------------------------------------------------------------------
      #
      # Take this value
      #
      obj.push([name, sub_tpl, prop, type, val, template])

      # -----------------------------------------------------------------------
      #
      # Emit tables
      #
      dump_files['val']  << "%d\t%s\n" % 
        [ val_id, val ]
      dump_files['join'] << "%d\t%d\t%d\t%d\t%d\n"    % 
        [ val_id, name_id, ids['prop'][prop], ids['type'][type], ids['sub_tpl'][sub_tpl] ]
      # puts "%7d|%7d|%-56s|%7d|%-31s|%-39s|%6d|%-20s|%s\n"  % [ val_id, name_id, name, ids['prop'][prop], prop, sub_tpl, ids['type'][type], type.gsub(%r!\^\^<http://www.w3.org/2001/XMLSchema\#([^>]+)>!,'\1'), val ]
      
      # another day, another dollar.
      val_id += 1
    end # line
  end # open input file  
  # make sure last obj. gets writ
  emit_obj(last_name, obj, obj_dump_dir, obj_dump_files) 
  # write ids
  emit_ids(ids, dump_files)
end

#
# spit out an object and all associated info
#
$objs_emitted = 0
def emit_obj(name, flat_obj, obj_dump_dir, obj_dump_files)
  # file to write to
  label = dump_label(name)
  obj_dump_files[label] ||= File.open("%s/objs_%s.yaml" % [obj_dump_dir, label], 'wb')  
  # helpfully announce our progress
  $objs_emitted += 1
  $stderr.print("%s %5d\t" % [label, $objs_emitted]) if (($objs_emitted % 1000) == 0)
  # write it
  obj_dump_files[label] << {name => flat_obj}.to_yaml[4..-1]
end

#
# for each identfiable field, 
# dump each id and its value,
# in id order
#
def emit_ids(ids, dump_files)
  # %w{prop type template sub_tpl} %w{name val join}
  FIELDS_W_ID.each do |field|
    id_vals = ids[field].sort_by{ |val, id| id }
    id_vals.each do |val,id| 
      dump_files[field] << ("%s\t%s\n" % [id, val]) 
    end
    dump_files[field+'_yaml'] << id_vals.to_yaml
  end  
end

# 
# partition the objects into more manageable size.
#
def dump_label(name)
  initial = name.to_s[0..0].downcase
  case 
    when initial == '%' then return 'zebra_beyond' # things left url-enc are high bit in disguise
    when initial <  'a' then return '0to9_and_sym'
    when initial <= 'z' then return initial
    else                     return 'zebra_beyond'
  end
end

#
# finds a dumping ground for the stat files.
# 
def open_dump_file(dumproot, filename, field, ext)
  File.open("%s/%s_%s.%s" % [dumproot, filename, field, ext], 'wb')
end

#
# takes the crappy sometimes-double-encoded name encoding of the dbpedia resources
# and tries to coerce them to their unencoded form; high-bit (unicode) characters
# are left percent encoded.
#
# FIXME -- TAB CR and LF are converted to \t \r and \n respectively, after being
# URL unencoded.  The dbpedia files come with sometimes %0A, etc embedded but more
# usually \n's; this leaves everything \ encoded but could pass through another 
# ctl character.
def unescape_7bit(str)
  str = str.gsub(/_percent_25/soi,        '%')
  str.gsub!(/%25/soi,                '%')
  str.gsub!(/_percent_(#{HEX7})/soi, "%#{$1}")
  str.gsub!(/%(#{HEX7})/soi){ $&[1,2].hex.chr }
  str.gsub!(/\n/so,                  '\\n')
  str.gsub!(/\r/so,                  '\\r')
  str.gsub!(/\t/so,                  '\\t')
  # str.gsub!(/%E2%80%93/so,           '-')
  str
end
HEX7 = '[0-7][a-f\\d]'

process_infoboxen_rdf3s(ARGV[0], ARGV[1])
