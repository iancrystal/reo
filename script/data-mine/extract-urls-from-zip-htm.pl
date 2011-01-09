open(LIST, $ARGV[0]) or die "Can't open:$!\n";

while ($line = <LIST>) {
  chomp $line;
  next if ($line =~ /^\s*$/); 
  #next if ($line !~ /==&amp;x=/);
  $line =~ s/==&amp;x=/==&x=/;
  if ($line =~ /<a href="(.*)" onclick=/) {
     print "$1\n";
  }
}

close LIST;
