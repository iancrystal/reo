$file = $ARGV[0] || "zip-sorted.txt";
open(LIST, "$file") or die "Can't open:$!\n";

$semd="C:/my/projects/reoagentsconnect/data-mine/out/sem";

system("mkdir -p $semd/zip/$line");
system("mkdir -p out/zip-htm");

$count=1;
while ($line = <LIST>) {
  chomp $line;
  next if ($line =~ /^\s*$/); 
  next if ((-f "out/zip-htm/$line.htm") || (-f "$semd/zip/$line"));
  $id=""; 
  $retries=0;
  while (!$id) {
    system("rm -f out/zip-htm/$line.htm");
    system("rm -f mst.done");
    system("start.exe \"c:/program files/google/chrome/application/chrome.exe\" www.reonetwork.com");
    sleep 3;
    system("mt save-zip-htms.mst /T $line");
    print "waiting for mst.done ...\n";
    while (! -f "mst.done") {
      sleep 1;
    }
    $id=`grep ContactID out/zip-htm/$line.htm`;
    if (!$id) {
      print "retrying $line ...\n";
      system("mt close-chrome.mst");
      sleep 3;
      ++$retries;
      if ("$retries" >= 3)  {
        system("rm -f out/zip-htm/$line");
        $id = "timeout";
      }
    }
    system("rm -rf out/zip-htm/${line}_files");
  }

  system("echo done > $semd/zip/$line");
  print "$line,$count\n";
  $count++;
}

close LIST;
