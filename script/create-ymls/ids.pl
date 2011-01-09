open (YAML, "agents.yml");
open (IDS, ">ids.txt2");

while ($line = <YAML>) {
  chomp $line;
  if ($line =~ /^([^ ]+):/) {
    $old_id = $1;
  } elsif ($line =~ /^  id:(.*)/) {
    $new_id = $1;
    print IDS "$old_id, $new_id\n";
    print "$old_id, $new_id\n";
  }
}

close YAML;
close IDS;
