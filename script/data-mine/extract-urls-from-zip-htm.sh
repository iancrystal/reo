zip=$1
workd=c:/tmp/reo/work/$zip
mkdir -p $workd

grep -i "a href=" out/zip-htm/$zip.htm | grep -i broker.cfm | grep -iv onmouseover | grep -iv json_dataset | grep -i onclick > c:/tmp/reo/extract-urls-from-zip-htm.tmp
perl extract-urls-from-zip-htm.pl c:/tmp/reo/extract-urls-from-zip-htm.tmp > $workd/$zip.urls
mv -f out/zip-htm/$zip.htm $workd
