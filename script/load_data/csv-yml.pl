$count = 15544;

open (LIST, $ARGV[0]);
while ($li = <LIST>) {
  chomp $li;
  print "$li\n";
  
  open (CSV, $li);
  $yml = $li;
  $yml =~ s/csv/yml/;
  open (YML, ">$yml");
  $base = $yml;
  $base =~ s/\.yml//;
  while ($line = <CSV>) {
    chomp $line;
  
    $line =~ s/[^\w- ,@]//g;
  
    ($id,$full_name,$first_name,$middle_name,$last_name,$suffix,$designations,$agency,$office_name,$office_address1,$office_address2,$office_city,$office_state,$office_zip,$office_county,$office_msa,$office_phone,$office_fax,$cell_phone,$email1,$email2,$email3,$email4,$website,$association,$license_type,$license_number,$license_issued,$license_expires,$home_address1,$home_address2,$home_city,$home_state,$home_zip,$home_county,$home_msa) = split(/\s*,\s*/, $line);
  
    if (grep(/^$base$/i, qw/zim_realtor_california2 zim_realtor_california3 zim_realtor_florida2 zim_realtor_texas2/)) {
      ($id,$full_name,$first_name,$middle_name,$last_name,$suffix,$designations,$agency,$office_name,$office_address1,$office_address2,$office_city,$office_state,$office_zip,$office_county,$office_msa,$office_phone,$office_fax,$cell_phone,$email1,$email2,$email3,$email4,$website,$association,$home_address1,$home_address2,$home_city,$home_state,$home_zip,$home_county,$home_msa,$license_type,$license_number,$license_issued,$license_expires) = split(/\s*,\s*/, $line);
    }
  
    next if ($last_name =~ /Last Name/);
  
    #print YML "${base}_$count:\n";
    print YML "---\n";
    print YML "id: $count\n";
    print YML "company: $agency\n";
    print YML "email1: $email1\n";
    print YML "email2: $email2\n";
    print YML "phone1: $office_phone\n";
    print YML "phone2: $cell_phone\n";
    print YML "fax: $office_fax\n";
    print YML "first_name: $first_name\n";
    print YML "middle_name: $middle_name\n";
    print YML "last_name: $last_name\n";
    print YML "suffix: $suffix\n";
    if ($home_address1) {
      print YML "physical_address1: $home_address1\n";
      print YML "physical_address2: $home_address2\n";
      print YML "physical_address_city: $home_city\n";
      print YML "physical_address_state: $home_state\n";
      print YML "physical_address_zip: $home_zip\n";
    } else {
      print YML "physical_address1: $office_address1\n";
      print YML "physical_address2: $office_address2\n";
      print YML "physical_address_city: $office_city\n";
      print YML "physical_address_state: $office_state\n";
      print YML "physical_address_zip: $office_zip\n";
    }
  
    ++$count;
  }
  close CSV;
  close YML;
}
close LIST;
