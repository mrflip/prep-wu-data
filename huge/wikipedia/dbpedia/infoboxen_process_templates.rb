#!/usr/bin/env ruby
$:.unshift ENV['HOME']+'/ics/code/lib/ruby/lib' # find infinite monkeywrench lib
require 'imw.rb'
require 'yaml'

$dump_head = "infobox_en"
$dump_dir  = "rawd/dump/#{$dump_head}"
$infobox_dir   = $dump_dir+"/#{$dump_head}_tpls"
$obj_dir   = $dump_dir+"/#{$dump_head}_objs" # /objs_g.yaml
puts $obj_dir

# 
def process_flat_obj_files(flat_obj_filenames)
  # open each tpl file exactly once, hold them all open
  infobox_files = {}
  infobox_types = {}
  flat_obj_filenames.each do |flat_obj_filename|
    process_flat_obj_file(infobox_files, infobox_types, flat_obj_filename)
  end
  
  # Emit the type info.
  YAML.dump(infobox_types, File.open("%s/%s.yaml" % [$dump_dir, 'types'], 'wb'))  
end

# spool out property lists into objects, emit them as templates.
def process_flat_obj_file(infobox_files, infobox_types, flat_obj_filename) 
  # This will take about a minute per file
  $stderr.print "Loading #{flat_obj_filename}... (#{Time.now})"
  flat_objs = YAML.load(File.open(flat_obj_filename))
  $stderr.puts "... done"
  # process each obj in it
  flat_objs.each do |name, flat_obj|
    # $stderr.puts("\n",'-'*75,name)
    tpls = obj_from_flat_obj(infobox_files, infobox_types, name, flat_obj, '')
  end
end

def emit_template(infobox_files, infobox_name, obj)
  # infobox_name = infobox_name.gsub(%r!\A\{\{Template:(.*)\}\}\Z!, "#{$1}")
  infobox_name = infobox_name.gsub(/[^\w\-_]/, '_')[0..80]
  infobox_files[infobox_name] ||= File.open("%s/infobox_%s.yaml" % [$infobox_dir, infobox_name], 'wb')  
  infobox_files[infobox_name] << obj.to_yaml[4..-1]    
end

#
# recursively ravel an object from a flat list of properties
# 
def obj_from_flat_obj(infobox_files, infobox_types, name, flat_obj, curr_sub_tpl)
  template  = ""
  templates = []
  curr_depth = curr_sub_tpl.blank? ? 0 : 1+curr_sub_tpl.count('/')
  # puts "%2d (%-50s): %s" % [curr_depth, curr_sub_tpl, flat_obj.to_json]
  obj = {}
  while (! flat_obj.empty?) do 
    # pull off properties in reverse order -- templates will thus come first
    name, sub_tpl, prop, type, val, new_tpl = flat_obj.pop  
    # where are we in the tree?
    sub_infobox_depth = sub_tpl.blank? ? 0 : 1+sub_tpl.count('/')    
    # sub_obj
    if    (sub_infobox_depth > curr_depth)
      # $stderr.puts "pushing into #{name}/#{sub_tpl}/#{prop}"
      flat_obj.push( [name, sub_tpl, prop, type, val, new_tpl] )
      begin 
        sub_obj = obj_from_flat_obj(infobox_files, infobox_types, name, flat_obj, sub_tpl)
        if ! sub_obj.blank? 
          warn "WTF complex sub-object #{sub_obj}" if sub_obj.length > 1
          sub_obj = sub_obj[0].shift[1].shift[1]
          bank_prop(obj,       name,     sub_tpl.split('/'), sub_obj) unless sub_obj.blank? 
          bank_type(infobox_types, template, sub_tpl.split('/'), sub_tpl)
        end
      rescue Exception => e
        $stderr.puts e.to_s
        $stderr.puts e.backtrace.join("\n")
        warn "WTF just happened? writing tpl #{template} w/ obj #{name}, prop !#{sub_tpl}!/!#{prop}!"
        next
      end
    
    # done this obj.
    elsif (sub_tpl != curr_sub_tpl) 
      # $stderr.puts "popping from #{curr_sub_tpl} : #{obj.to_json}"
      flat_obj.push( [name, sub_tpl, prop, type, val, new_tpl] )
      templates.push( {template => obj} )        unless obj.empty?
      emit_template(infobox_files, template, obj)    unless obj.empty? 
      return templates

    # template
    elsif    (prop == 'wikiPageUsesTemplate')
      templates.push( {template => obj} )        unless obj.empty? 
      emit_template(infobox_files, template, obj)    unless obj.empty?
      obj      = {}
      template = val
      
    # subtype
    elsif ( (prop =~ %r{\A(relatedInstance|pagename)\Z}o) && (val =~ %r{\[\[#{Regexp.escape(name)}/(.*)\]\]}) )
      # val will be of the form [['O_Sole_Mio/succession_box3]]
      prop =~ %r{\A(relatedInstance|pagename)\Z}o
      type     = 'wpinfobox_'+prop
      template = prop
      # use related value to indicate property
      val      =~ %r{\[\[#{Regexp.escape(name)}/(.*)\]\]}
      prop     = $1
      props    = prop.split('/')
      # $stderr.puts "Got related instance #{prop} of #{val}"
      # bank_prop(obj,       name,     props.most, props.last)      
      # bank_type(infobox_types, template, props.most, type)
    
    elsif (val  =~ %r!\[\[#{Regexp.escape(name)}/(.*)\]\]!)
      # val will be of the form [['O_Sole_Mio/succession_box3]]
      type = prop
      if %r!\[\[#{Regexp.escape(name)}/(.*)\]\]!.match(val) then prop = $1
      else warn "WTF inconsistent sub_type reference to #{name} in #{type} as #{val}" end
      # $stderr.puts "Got subtype #{prop} of #{val}"
      props = prop.split('/')
      # bank_prop(obj,       name,     props.most, props.last)      
      # bank_type(infobox_types, template, props.most, type)
    
    # simple property    
    else  (sub_tpl == curr_sub_tpl) 
      bank_prop(obj,       name,     prop, val)
      bank_type(infobox_types, template, prop, type)
    end
  end
  templates.push( {template => obj} )       unless obj.empty?
  emit_template(infobox_files, template, obj)   unless obj.empty?
  templates
end

def bank_prop(obj, name, prop, val)
  # obj[name]       ||={}; obj[name][template] ||={}; 
  # obj[name][template][prop] ||=[]; obj[name][template][prop].unshift(val) # use shift to unreverse the vals
  # obj[name][template][prop]
  hash_stuff(obj, val, [name, prop].flatten.compact)
end

def bank_type(infobox_types, tpl, prop, type) 
  hash_stuff_count(infobox_types, type, [tpl, prop].flatten.compact)

end

def hash_stuff(hsh, val, keys)
  #puts [hsh, val, keys].to_yaml
  node = keys.most.inject(hsh) do |h_tree, k| 
    h_tree[k] ||= {}
    if (! h_tree[k].is_a?(Hash)) then h_tree[k] = { 0 => h_tree[k] } end
    h_tree[k]
  end
  if !node.include?(keys.last)
    # first time, try it as a scalar.
    node[keys.last] = val
  elsif node[keys.last].is_a?(Hash)
    node[keys.last][node[keys.last].length] = val
  else
    node[keys.last] = { 0 => node[keys.last], 1 => val }
  end
  hsh
end

def hash_stuff_count(hsh, val, keys)
  #puts [hsh, val, keys].to_yaml
  node = keys.inject(hsh) do |h_tree, k| 
    h_tree[k] ||= {}
    if (! h_tree[k].is_a?(Hash)) then h_tree[k] = { 0 => h_tree[k] } end
    h_tree[k]
  end
  node[val] ||= 0
  node[val] +=  1
  hsh
end

mkdir_p $infobox_dir
process_flat_obj_files(Dir[$obj_dir+'/*.yaml'])
