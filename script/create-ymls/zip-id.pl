open (YAML, "zipcodes.yml");
open (IDS, ">zip-id.txt");

while ($line = <YAML>) {
  chomp $line;

  if ($line =~ /^([^ ]+):/) {
    $zip = $1;
  } elsif ($line =~ /^  id:(.*)/) {
    $id = $1;
    print IDS "$zip $id\n";
    print "$zip $id\n";
  }
}

close YAML;
close IDS;
