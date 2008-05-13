#!/usr/bin/env ruby
$:.unshift ENV['HOME']+'/ics/code/lib/ruby/lib' # find infinite monkeywrench lib
require 'imw.rb'
require 'yaml'

$dump_head   = "infobox_en"
$dump_dir    = "rawd/dump/#{$dump_head}"
$infobox_dir = $dump_dir+"/#{$dump_head}_tpls"
$obj_dir     = $dump_dir+"/#{$dump_head}_objs" # /objs_g.yaml
$fixd_dir    = File.expand_path("~/ics/data/fixd/huge/wikipedia/dbpedia")
mkdir_p $fixd_dir

def load_fields()
  fields_filename = "%s/%s" % [$dump_dir, "types.yaml"]
  # fields_filename = "/tmp/ics/types_short.yaml"
  $stderr.puts "Fields loading from %s" % [fields_filename]
  infobox_fields = YAML.load(File.open(fields_filename))
end

def load_schema()
  schema_filename = "dbpedia_infoboxen_template.icss.yaml"
  $stderr.puts "Schema loading from %s" % [schema_filename]
  infobox_schema  = YAML.load(File.open(schema_filename))
  infobox_schema['infochimps_schema_template']
end

def describe_type(type, count)
  desc = { }
  case
  when (type =~ %r{@(\w\w)})
    # string
    lang = $1
    desc = {'desc' => "String",  'datatype' => 'string', 'tags' => "string lang:#{lang}"}
    desc['desc'] += " with language code '#{lang}'" if (lang != 'en')
  when (type =~ %r{(link_ext)})
    # External link
    desc = {'desc' => "Link to an external site", 'datatype' => $1,       'tags' => 'url',           'units' => 'url'}
  when (type =~ %r{(link_wp)})
    # Wikipedia link
    desc = {'desc' => "Wikpedia link",            'datatype' => $1,       'tags' => 'url wikipedia', 'units' => 'url'}
  when (type =~ %r{(WP:Template)})
    # Infobox template instance
    desc = {'desc' => "Infobox instance",         'datatype' => $1,       'tags' => 'url wikipedia infobox'}
  when (type =~ %r{\^\^<http://www.w3.org/2001/XMLSchema#(.*)>})
    # integer decimal gYear gYearMonth date
    datatype       = $1
    humanized_type = (datatype).gsub(/^gYear/, 'Year').capitalize
    desc = {'desc' => "#{humanized_type}",        'datatype' => datatype, 'tags' => datatype}
  when (type =~ %r{\^\^<http://dbpedia.org/units/(.*)>})
    # Rank Kilometer Percent Inches Centimeter Dollar 
    # Kilogramm Meter Millimeter feet Euro Pound Gramm 
    # Kelvin Megabyte Yen GigaByte
    datatype       = $1
    humanized_type = (datatype).gsub(/^([Gg]ram)m/, "#{$1}")
    desc = {'desc' => "Number with units #{$1}",  'datatype' => datatype, 'tags' => datatype, 'units' => datatype }
  else 
    # warn "Can't grok type '%s'" % type
    desc = {'desc' => type, 'datatype' =>  '(unknown)', 'tags' => type.gsub(/:/, '_')}
  end
  desc['desc'] += " [#{count} occurrences]"
  desc
end

#
# fields are
#  name: { type_1 => #count_1, ... }
# which we need to squash into one field for the schema
def describe_field(name, types)
  if types.length == 1 
    type, count = types.shift()
    field = { 'name' => name }.merge(describe_type(type,count))
    field['desc']  = name + " - " + field['desc']
    field['count'] = (count.is_a? Numeric) ? count : 0
  else
    desc, datatype, tags, units = [], [], [], []
    total_count = 0
    # starting with largest, summarize all the types involved.
    types.sort_by{|t,c| (c.is_a?(Numeric) ? -c : 0)}.each do |type, count|
      dt = describe_type(type, count)
      desc << dt['desc']; datatype << dt['datatype']; tags << dt['tags']; 
      total_count += (count.is_a? Numeric) ? count : 0
    end
    field = { 'name' => name.titleize, 'uniqid' => name, 
      'desc'  => "#{name.titleize} - Multiple types: "+desc.join(", "),
      'count' => total_count,
      'datatype' => datatype.join(' '), 'tags' => tags.join(' '), 'units' => units.compact.join(' ') }
  end
  field.reject{|k,v| v.blank?}
end

def get_schema_basename(infobox_name)
  "infobox_" + infobox_name.gsub(%r![^\w\-_]!,'_')[0..80]
end

#
# Stuff the dataset-specific info into a schema file, 
# dump same into the right fixd/ directory
#
def process_infobox_schema(infobox_info)
  infoboxes                 = load_fields()
  infobox_collection_schema = load_schema()
  # infobox_collection_schema = { 'a' => 'b', 'notes' => {} }
  
  num_done = 0
  $stderr.puts "Processing fields & type information:"
  infoboxes.sort_by{|n,f| n}.each do |infobox_name, raw_fields|
    next if infobox_name.blank?
    # KLUDGE
    schema_basename = get_schema_basename(infobox_name)
    schema_filename = "%s/%s.icss.yaml" % [$fixd_dir, schema_basename]
    infobox_name = 'infobox_' + infobox_name.gsub(%r![^\w\-_]!,'_')[0..80]
    if (!infobox_info.include?(infobox_name)) then puts infobox_name ; next ; end
    rows = infobox_info[infobox_name]['rows']
    # Skip crappy ones
    next if rows < 10
    
    # Stuff in dataset-specific info
    fields = raw_fields.map do |name, types|
      describe_field(name, types)
    end
    interesting_fields = 0
    fields.each do |field|
      field['notnull_fraction'] = field['count'].to_f / rows
      # let's call it interesting if in > 10% of objs or there's more than 100 of them.
      interesting_fields += 1 if 
        (field['notnull_fraction'] > 0.1 || field['count'] > 100) 
    end
    infobox_schema = infobox_collection_schema.deep_merge({ 'fields' => fields })
    infobox_schema['name']   = infobox_name.titleize
    infobox_schema['uniqid'] = infobox_name    
    infobox_schema['notes']['desc']   = "All of the '#{infobox_name.titleize}' (#{infobox_name}) infoboxes from wikipedia."
    infobox_schema['notes']['interesting_fields'] = interesting_fields
    infobox_schema['formats'] = { 'yaml' =>{}  }
    dataset_tags = infobox_name.gsub(/infobox_/,'').gsub(/\d+(team|round)(bracket)/){"#{$1} #{$2}"}.gsub(/[\-\_]/, ' ')
    infobox_schema['tags']    = 'infobox infoboxen wikipedia template dbpedia templates ' +
      dataset_tags.humanize.downcase
    # s/infobox_//g; s/\d+(team|round)(bracket)/$1 $2/; s/[\-_]/ /g
    
    # Dump to file
    # KLUDGE
    infobox_schema['notes']['shape'] = "{kind:object, rows:%s, cols:%s}" % [rows, fields.length]
    File.open(schema_filename, 'wb') do |f|
      f << [{ 'infochimps_schema' => infobox_schema }].to_yaml()
    end
    fixd_dataset_dir = "%s/%s-yaml" % [$fixd_dir, schema_basename]
    # dataset directory
    mkdir_p fixd_dataset_dir    
    # schema
    cp(schema_filename, fixd_dataset_dir)
    # payload
    cp($infobox_dir+'/infobox_'+schema_basename.gsub(%r!^infobox_!,'')+'.yaml', fixd_dataset_dir)    
    # Announce progress
    num_done += 1; $stderr.puts(" #%-7d: %s"%[num_done, infobox_name]) if ((num_done % 200) == 0)
  end
end

#
# number of rows, columns, filesize.
#
def qualify_schema(filenames)
  infos_filename = $dump_dir+"/infobox_infos.yaml"
  if File.exists?(infos_filename)
    infobox_info = YAML.load(File.open(infos_filename))
  else 
    infobox_info = {}
    num_done = 0
    $stderr.puts "Finding size:"
    filenames.each do |filename|
      tpl = YAML.load(File.open(filename))
      infobox_name = File.basename(filename, '.yaml')
      infobox_info[infobox_name] ||= {}
      infobox_info[infobox_name]['rows'] = tpl.length
      # Announce progress
      num_done += 1; $stderr.puts(" #%-7d: %s"%[num_done, filename]) if ((num_done % 10) == 0)
    end
    # record to disk
    File.open(infos_filename, 'wb') do |f| f << YAML.dump(infobox_info) end
  end
  infobox_info
end




mkdir_p $infobox_dir
infobox_info = qualify_schema(Dir[$infobox_dir+'/*.yaml'])
process_infobox_schema(infobox_info)

# TODO:
# total number of fields;
# total number of rows
# cull wacky fields
# cull crappy infoboxes
#
# cat rawd/orig/infoboxproperties_en.csv | grep -v "http://www.w3.org/1999/02/22-rdf-syntax-ns#type" | sort -u
#
# Dump statistics about them
# 
# 'wpinfobox_'+subtype for subtypes
