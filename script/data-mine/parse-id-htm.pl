$zip = $ARGV[0];
$id = $ARGV[1];

$semd="C:/my/projects/reoagentsconnect/data-mine/out/sem";

open(LIST, "c:/tmp/reo/work/$zip/$id.htm") or die "Can't open:$!\n";
open(OUT, ">>out/txt/$zip-agents.txt") or die "Can't open:$!\n";

sub reset_ins {
  $in_physical_address = 0;
  $in_mailing_address = 0;
  $in_bio_cred = 0;
  $in_service_areas = 0;
}

reset_ins;

$count=1;

while ($line = <LIST>) {
  chomp $line;
  next if ($line =~ /^\s*$/); 

  if ($line =~ /^\s*Email\s*[0-9]?:\s*$/) {
    reset_ins;
  }
  if ($line =~ /^\s*Lic #:/) {
    reset_ins;
  }
  if (($line =~ /<\/table>/) && $in_service_areas) {
    reset_ins;
  }
  if ($in_physical_address) {
    $line =~ s/<br\/?>//g;
    $line =~ s/^\s*//;
    push @mailing_address, $line;
  } elsif ($in_mailing_address) {
    $line =~ s/<br\/?>//g;
    $line =~ s/^\s*//;
    push @physical_address, $line;
  } elsif ($in_bio_cred) {
     if ($line !~ /bContent/) {
       $line =~ s/^\s*//;
       push @bio_cred, split(/<br>/,$line);
       $in_bio_cred = 0;
     }
  } elsif ($in_service_areas) {
     if ($line =~ /<th valign=.*>(.*)</) {
       $city = $1;
     } elsif ($line =~ /<td valign=.*>(.*)</) {
       $zips = $1;
       $service_area = "$city :: $zips";
       push (@service_areas,$service_area);
     }
  } elsif ($line =~ /class="aName">(.*),<span>(.*)<\/span>/) {
    ($name,$company) = ($1,$2);
    reset_ins;
  } elsif ($line =~ /<b>Physical Address<\/b>/) {
     reset_ins;
     $in_physical_address = 1; 
  } elsif ($line =~ /<b>Payment\/Mailing Address<\/b>/) {
     reset_ins;
     $in_mailing_address = 1; 
  } elsif ($line =~ />\s*Biography\s*and\s*Credentials\s*</) {
     reset_ins;
     $in_bio_cred = 1; 
  } elsif ($line =~ />Service\s*Areas</) {
     reset_ins;
     $in_service_areas = 1; 
  } elsif ($line =~ /Phone\s*1:\s*([-\d ]+)/) {
    $phone1 = $1;
    reset_ins;
  } elsif ($line =~ /Phone\s*2:\s*([-\d ]+).*Fax:\s*([-\d]*)/) {
    ($phone2,$fax) = ($1,$2);
    reset_ins;
  } elsif ($line =~ /mailto:(.*)\?subject/) {
    $email = $1;
    reset_ins;
  } elsif ($line =~ /<img\s*src="(.*broker_images.*)"\s*alt="/) {
    $jpg_url = $1;
    reset_ins;
  }
}

$physical_address = join(" ::: ", @physical_address);
$mailing_address = join(" ::: ", @mailing_address);
$bio_cred = join(" ::: ", @bio_cred);
$service_areas = join(" ::: ", @service_areas);

if ($jpg_url) {
  system("mkdir -p out/jpg/$zip");
  system("curl \"$jpg_url\" > out/jpg/$zip/$id.jpg");
}

if ($name) {
  print "$count\n";
  print OUT "$zip ::::: $id ::::: $name ::::: $company ::::: $physical_address ::::: $mailing_address ::::: $email ::::: $phone1 ::::: $phone2 ::::: $fax ::::: $bio_cred ::::: $service_areas ::::: $jpg_url\n";
  ++$count;
}

system("echo done > $semd/id/$id");

close LIST;
close  OUT;
