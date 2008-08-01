#egrep 'href=|src=' *.php* | \
#    perl -ne 'for $m (m{((?:logo|team)\.php\?(?:id|t|lo)=\w+)}g) {
#               printf "wget -nv -erobots=off --no-clobber -nH \"http://sportslogos.net/$m\"\n"; }'


( for foo in logo team league ; do 
    grep '<img' ${foo}*.php*  | \
    perl -ne 'm{^.*img[^>]*src="(?:http://(?:[^\.]*\.)?sportslogos.net|..)/([^\.]*)/([^\./]*\.gif)"[^>]*alt="\s*([^"]*?)\s*".*} or next;
        (my ($dir, $rmt, $named)) = ($1, $2, $3);
        $named =~ s/&#\d+;//go;
        # the following funny chars are left in: ()@/.,-&#\s
        $named =~ tr/'"'"'\*//d;
        $named =~ tr/;/,/;
        $named =~ tr/\/\xe3\xe9\xed\xF4\xFA\xFC/-aeiouu/;
        my $url    = "http://sportslogos.net/$dir/$rmt";
        my $saveas = "$dir/$named.gif";
	print "mkdir -p \"$dir\"\n";'
 done; ) | sort -u

# ( for foo in logo team league ; do 
#     grep '<img' ${foo}*.php*  | \
#     perl -ne 'm{^.*img[^>]*src="(?:http://(?:[^\.]*\.)?sportslogos.net|..)/([^\.]*)/([^\./]*\.gif)"[^>]*alt="\s*([^"]*?)\s*".*} or next;
#         (my ($dir, $rmt, $named)) = ($1, $2, $3);
#         $named =~ s/&#\d+;//go;
#         # the following funny chars are left in: ()@/.,-&#\s
#         $named =~ tr/'"'"'\*//d;
#         $named =~ tr/;/,/;
#         $named =~ tr/\/\xe3\xe9\xed\xF4\xFA\xFC/-aeiouu/;
#         my $url    = "http://sportslogos.net/$dir/$rmt";
#         my $saveas = "$dir/$named.gif";
# 	print "if [ -a \"$saveas\" ] ; then echo Skipping \"$saveas\" ; else wget -nv -erobots=off --no-clobber \"http://sportslogos.net/$dir/$rmt\"\t-O \"$dir/$named.gif\" ; fi\n";'
#   done; ) | sort -u
