open(BAD, "zipcodes.badid");
open(GOOD, ">zipcodes.good");
$count = 14852;
while ($line = <BAD>) {
  chomp $line;
  if ($line =~ /^  id:/) {
    print GOOD "  id: $count\n"; 
    ++$count;
  } else {
    print GOOD "$line\n";
  }
}
close BAD;
close GOOD;
