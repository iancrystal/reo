
open (FILE, "ids.txt");
while ($line = <FILE>) {
  chomp $line;
  ($oldid, $newid) = split(/,\s*/, $line);
  $ids{$oldid} = $newid;
}
close FILE;

open (FILE, "oldid-zips.txt");
while ($line = <FILE>) {
  chomp $line;
  ($oldid, $zips) = split(/:\s+/, $line);
  $oldid_zips{$oldid} = $zips;
}
close FILE;

open (FILE, "zip-id.txt");
while ($line = <FILE>) {
  chomp $line;
  ($zip, $id) = split(/\s+/, $line);
  $zip_id{$zip} = $id;
}
close FILE;

open (YAML, ">agents_zipcodes.yml");
open (LOG, ">create-habtm.log");
foreach $oldid (keys %oldid_zips) {
  $newid = $ids{$oldid};
  $zips = $oldid_zips{$oldid};
  @zips = split(/\s+/,$zips);
  foreach $zip (@zips) {
    $zipid = $zip_id{$zip};
    if ($zipid) {
      print YAML "${oldid}_$zip:\n";
      print YAML "  agent_id: $newid\n";
      print YAML "  zipcode_id: $zipid\n";
    } else {
      print LOG "$zip not in db\n";  
    }
  }
}
close LOG;
close YAML;
