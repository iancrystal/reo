$zip=$ARGV[0];
$semd="C:/my/projects/reoagentsconnect/data-mine/out/sem";

$workd = "c:/tmp/reo/work/$zip";
@files = <$workd/*.htm>;
foreach $file (@files) {
  $file =~ /.*\/(.*).htm/;
  $id = $1;
  next if ($id =~ /[0-9]{5}/);
  if (! -f  "$semd/id/$id") {
    print "parsing $zip/$id\n";
    system("perl parse-id-htm.pl $zip $id");
  } else {
    print "skipping parsing of $zip/$id ...\n";
  }
}
