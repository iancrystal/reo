$zip = $ARGV[0];
$id = $ARGV[1];

open(LIST, "c:/tmp/reo/work/$zip/$id.htm") or die "Can't open:$!\n";

while ($line = <LIST>) {
  chomp $line;
  next if ($line =~ /^\s*$/); 

  if ($line =~ /Phone\s*1:\s*([-\d ]+)/) {
    $phone1 = $1;
  } elsif ($line =~ /Phone\s*2:\s*([-\d ]+).*Fax:\s*([-\d ]*)/) {
    ($phone2,$fax) = ($1,$2);
  }
}

print "$phone1:$phone2:$fax\n";

close LIST;
