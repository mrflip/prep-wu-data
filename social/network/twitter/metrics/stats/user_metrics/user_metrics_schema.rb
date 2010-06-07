
  # class Script < Wukong::Script
  #   def initialize *args
  #     super *args
  #     case
  #     when options[:dump_head]
  #       $dumper = $stdout
  #       $dumper.print("%15s\t"%"rsrc")
  #       UserMetrics.members.zip(UserMetrics.mtypes).each_with_index{|mt,i| m,t=mt; i=i+2; $dumper.print case t.to_s.to_sym when :String, :Bignum then "%2d%12s\t"%[i,m[0..14]] ; when :DateTime then "%2d%21s\t"%[i,m[0..21]] when :Float, :Integer then "%2d%7s\t"%[i,m[0..6]] else "%2d%s\t"%[i,m] end } ; $dumper.puts
  #       exit
  #     when options[:dump_names]
  #       $stdout.puts( (['rsrc'] + UserMetrics.mnames).join("\t") )
  #       exit
  #     when options[:dump_sql]
  #       puts "\n    #{UserMetrics.to_sql_str}"
  #       exit
  #     end
  #   end
  # end
