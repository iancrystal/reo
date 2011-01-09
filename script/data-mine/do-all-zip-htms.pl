$count=1;
 
@files = <out/zip-htm/*.htm>;
foreach $file (@files) {
  $file =~ /.*\/([0-9].*).htm/;
  $zip = $1;
  system("sh extract-urls-from-zip-htm.sh $zip");
  system("perl curl-urls-to-id-htm.pl $zip");
  system("perl parse-all-id-htms.pl $zip");
  print "$zip,$count\n";
  ++$count;
} 
