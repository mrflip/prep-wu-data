find . -iname "*.xls" -exec dirname {} \;  | sort -u > statab-dirs-xls.txt
find . -iname "*.xls" -exec cp {} ~/infochimp/rawd/world/us/statisticalabstract/xls/{} \;
find . -iname "*.xlw" -exec cp {} ~/infochimp/rawd/world/us/statisticalabstract/xls/{} \;
# There's not much else left:
find . -type f | grep -P -v '\.(html?|pdf|xl[sw]|svn.*)$'

# cd ~/infochimp/rawd/world/us/statisticalabstract/
cd ~/infochimp/rawd/world/us/statisticalabstract
cp ~-/statab-dirs-xls.txt .
for foo in `cat statab-dirs-xls.txt` ; do mkdir -p csv/$foo ; done
