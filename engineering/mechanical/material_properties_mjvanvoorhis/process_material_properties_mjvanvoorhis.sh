cp ripd/*.gif fixd/
for foo in ripd/t*.htm ; do cp $foo rawd/`basename $foo .htm`.html ; done


for foo in `egrep '^name:' schema_datasets_material_properties_mjvanvoorhis.icss.yaml |
	perl -ne "
	  s/^name:\s+'(.*) - T(\d+)'"'\s+$/lc "$2_$1"/e; s/\W+/_/g;
	  print "$_\n";'` ; do
	    touch $foo.flat.txt ;
	  done
