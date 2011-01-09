 
@files = <out/txt/*.txt>;

open(LOG, ">create-yaml.log") or die "Can't open:$!\n";
open(YAML, ">out/agents.yml") or die "Can't open:$!\n";

$count = 1;

foreach $file (@files) {
  open(TXT, $file) or die "Can't open:$!\n";

  while ($line = <TXT>) {
    chomp $line;
    next if ($line =~ /^\s*$/);

    $id=""; $company=""; $email=""; $phone1=""; $phone2=""; $fax=""; $bio_cred=""; $first_name=""; $second_name=""; $last_name=""; $suffix=""; $street=""; $street2=""; $city=""; $state=""; $zipc=""; $street=""; $street2=""; $city=""; $state=""; $zipc="";
    ($zip, $id, $name, $company, $addr1, $addr2, $email, $phone1, $phone2, $fax, $bio_cred, $areas, $jpg_url ) = ("", "", "", "", "", "", "", "", "", "", "", "","");

    $line=~/(.*) ::::: (.*) ::::: (.*) ::::: (.*) ::::: (.*) ::::: (.*) ::::: (.*) ::::: (.*) ::::: (.*) ::::: (.*) ::::: (.*) ::::: (.*) ::::: (.*)/;
    ($zip, $id, $name, $company, $addr1, $addr2, $email, $phone1, $phone2, $fax, $bio_cred, $areas, $jpg_url ) = ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12,$13);

    next if (!$id);

    @fields = ();
    @fields = split(/\s+/,$name);
    $last_name = $fields[scalar @fields - 1];
    $first_name = $fields[0];
    $middle_name = $fields[scalar @fields -2];
    if ($last_name =~ /^(jr\.?|sr\.?|junior|senior|I{1,3}|IV|V|2nd|second|3rd|third)$/i) {
      print LOG "with_suffix : $id : $name\n";
      print "with_suffix : $id : $name\n";
      $suffix = $last_name;
      $last_name = $fields[scalar @fields -2];
      $middle_name = $fields[scalar @fields -3];
    }
    if ($middle_name eq $first_name) {
      $middle_name = "";
    }

    if (length $phone1 < 10 || length $phone2 < 10 || length $fax < 10) {
       $bad_phone1 = $phone1; $bad_phone2 = $phone2; $bad_fax = $fax;
       $phones = `perl parse-phone.pl $zip $id`;
       chomp $phones;
       ($phone1,$phone2,$fax) = split(/:/,$phones);
       print LOG "fixed_phone : $id : $name : $bad_phone1: $phone1 : $bad_phone2: $phone2 : $bad_fax : $fax\n";
       print "fixed_phone : $id : $name : $bad_phone1: $phone1 : $bad_phone2: $phone2 : $bad_fax : $fax\n";
    }
    $bio_cred =~ s///g;
    $bio_cred =~ s/ ::: /\n/g;
    #$bio_cred =~ s/[\x80-\xFF]//g;
    $bio_cred =~ s/[^[:ascii:]]//g;
    $bio_cred =~ s/ {2,}/ /g;
    #$bio_cred =~ s/\x0A /\x0A/g;
    $bio_cred =~ s/\n /\n/g;
    $bio_cred =~ s/\n/\n    /g;

    print YAML "$id:\n";

    print YAML "  id: $count\n";
    $company =~ s/[:?]//g;
    print YAML "  company: $company\n";
    $email1 =~ s/[:?]//g;
    print YAML "  email1: $email\n";
    $email2 =~ s/[:?]//g;
    print YAML "  email2: \n";
    $phone1 =~ s/[:?]//g;
    print YAML "  phone1: $phone1\n";
    $phone2 =~ s/[:?]//g;
    print YAML "  phone2: $phone2\n";
    $fax =~ s/[:?]//g;
    print YAML "  fax: $fax\n";
    print YAML "  bio_cred: |-\n";
    print YAML "    $bio_cred\n";
    print YAML "  photo_url: /images/$id.jpg\n";
    $first_name =~ s/[:?]//g;
    print YAML "  first_name: $first_name\n";
    $middle_name =~ s/[:?]//g;
    print YAML "  middle_name: $second_name\n";
    $last_name =~ s/[:?]//g;
    print YAML "  last_name: $last_name\n";
    $suffix =~ s/[:?]//g;
    print YAML "  suffix: $suffix\n";

#print YAML "addr2: $addr2\n";
    @fields = ();
    $last = ""; $street = ""; $city = ""; $state = ""; $zipc = "";
    @fields = split(/ ::: /, $addr2);
    $last = $fields[scalar @fields - 1];
    $street = $fields[scalar @fields - 2];
    if ($last =~ /([^,]+)(,?\s*|\s+)([a-z][a-z])(,?\s*|\s+)([0-9]{5})/i) {
       $city = $1; $state = $3; $zipc = $5;
    }
    if ($street =~ /(attn|attention|c\/o|care.*off)/i) {
      $street = $fields[scalar @fields - 3];
      $street2 = $fields[scalar @fields - 2];
    }
    if ($city =~ /(attn|attention|c\/o|care.*off)/i) {
      $city =~ s/(.*) //;
      $tmp = $1;
      $street = $street2 if ($street2);
      $street2 = $tmp;
    } 
    $street =~ s/[:?]//g;
    $street2 =~ s/[:?]//g;
    $city =~ s/[:?]//g;
    @city = split(/\s+/,$city);
    if (scalar @city > 4) {
      $city =~ s/(.*) //;
      $tmp = $1;
      $street = $street2 if ($street2);
      $street2 = $tmp;
    }
    if ($street =~ /(attn|attention|c\/o|care.*off)/i) {
      if ($street2) {
        $tmp = $street;
        $street = $street2;
        $street2 = $tmp;
      }
    }
    print YAML "  physical_address1: $street\n";
    print YAML "  physical_address2: $street2\n";
    print YAML "  physical_address_city: $city\n";
    print YAML "  physical_address_state: $state\n";
    print YAML "  physical_address_zip: $zipc\n";

#print YAML "addr1: $addr1\n";
    @fields = ();
    $last = ""; $street = ""; $city = ""; $state = ""; $zipc = "";
    @fields = split(/ ::: /, $addr1);
    $last = $fields[scalar @fields - 1];
    $street = $fields[scalar @fields - 2];
    if ($last =~ /([^,]+)(,?\s*|\s+)([a-z][a-z])(,?\s*|\s+)([0-9]{5})/i) {
      $city = $1; $state = $3; $zipc = $5;
    }
    if ($street =~ /(attn|attention|c\/o|care.*off)/i) {
      $street = $fields[scalar @fields - 3];
      $street2 = $fields[scalar @fields - 2];
    }
    if ($city =~ /(attn|attention|c\/o|care.*off)/i) {
      $city =~ s/(.*) //;
      $tmp = $1;
      $street = $street2 if ($street2);
      $street2 = $tmp;
    } 
    $street =~ s/[:?]//g;
    $street2 =~ s/[:?]//g;
    $city =~ s/[:?]//g;
    @city = split(/\s+/,$city);
    if (scalar @city > 4) {
      $city =~ s/(.*) //;
      $tmp = $1;
      $street = $street2 if ($street2);
      $street2 = $tmp;
    }
    if ($street =~ /(attn|attention|c\/o|care.*off)/i) {
      if ($street2) {
        $tmp = $street;
        $street = $street2;
        $street2 = $tmp;
      }
    }
    print YAML "  mailing_address1: $street\n";
    print YAML "  mailing_address2: $street2\n";
    print YAML "  mailing_address_city: $city\n";
    print YAML "  mailing_address_state: $state\n";
    print YAML "  mailing_address_zip: $zipc\n";
    print "done with $count\n";
    ++$count;
  }
} 
close LOG;
close YAML;
close TXT;
