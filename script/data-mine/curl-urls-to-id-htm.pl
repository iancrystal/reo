$zip = $ARGV[0];
$workd="c:/tmp/reo/work/$zip";
$semd="C:/my/projects/reoagentsconnect/data-mine/out/sem";

open(LIST, "$workd/$zip.urls") or die "Can't open:$!\n";

while ($line = <LIST>) {
  chomp $line;
  next if ($line =~ /^\s*$/); 
  if ($line =~ /ContactID=([^=]*)=/) {
    $contact_id = $1;
    $contact_id =~ s/&//g;
    if (! -f "$semd/id/$contact_id") {
      print "curling $contact_id\n";
      system("curl \"$line\" > $workd/$contact_id.htm");
    } else {
      print "skipping curling of $contact_id\n";
      #system("echo $contact_id >> c:/tmp/reo/duplicates");
    }
  }
}

