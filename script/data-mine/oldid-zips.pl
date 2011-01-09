 
@files = <out/txt/*.txt>;

#open(LOG, ">oldid-zips.log") or die "Can't open:$!\n";
open(OUT, ">out/oldid-zips.txt") or die "Can't open:$!\n";

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
    $last = ""; $street = ""; $city = ""; $state = ""; $zipc = "";
    @fields = split(/ ::: /, $addr2);
    $last = $fields[scalar @fields - 1];
    $street = $fields[scalar @fields - 2];
    if ($last =~ /([^,]+)(,?\s*|\s+)([a-z][a-z])(,?\s*|\s+)([0-9]{5})/i) {
       $city = $1; $state = $3; $zipc = $5;
    }

    $rest = $areas;
    $zips="$zipc";
    push @zips, $zipc;
    while ($rest) {
      $rest =~ /([0-9]{5})(.*)/;
      $z=$1;$rest="$2";
      if (!grep(/$z/,@zips)) {
        $zips = "$zips $z";
        push @zips, $z;
      }
    }
    print OUT "$id: $zips\n";
    print "done with $count\n";
    ++$count;
  }
} 
#close LOG;
close OUT;
close TXT;
