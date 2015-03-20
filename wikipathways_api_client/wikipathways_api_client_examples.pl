# use lib '..';

use wikipathways_api_client;

# my @listOrganisms = wikipathways_api_client::listOrganisms();
# foreach my $organisms (@listOrganisms) {
# 	print $organisms, "\n";
# }	

# my @listP = wikipathways_api_client::listPathways('Equus caballus');
# foreach my $record (@listP) {
#   for my $key (sort keys(%$record)) {
#       my $val = $record->{$key};
#       print "$key:\t$val","\n";
#     }
#     print "\n";
# }

# my %pathwayInfo = wikipathways_api_client::getPathwayInfo('WP528');
# while ((my $key,my $value) = each(%pathwayInfo)){
#      print $key, "\t",$value, "\n";
# }

# my %pathwayInfo = wikipathways_api_client::getPathway('WP274','77669');
# # my %pathwayInfo = getPathway('WP209');
# while ((my $key,my  $value) = each(%pathwayInfo)){
#     print $key, "\t",$value, "\n";
# }

# my %pathwayHistory = wikipathways_api_client::getPathwayHistory('WP274');
# for my $key (sort keys(%pathwayHistory)) {
#     if ($key eq "history"){
#       foreach my $record (@{$pathwayHistory{$key}}) {
# # 	while ((my $k,my  $v) = each(%$record)){
# 	print "History:\n";
# 	for my $k (sort keys(%$record)){
# 	  my $v = $record->{$k};
# 	  print $k, "\t",$v, "\n";
# 	}
# 	print "\n";
#       }
#     }
#     else{
#     print $key, "\t",$pathwayHistory{$key}, "\n";
#     }
# }

# my @listP = wikipathways_api_client::getRecentChanges('20070522221730');
# foreach my $record (@listP) {
#   for my $key (sort keys(%$record)) {
#       my $val = $record->{$key};
#       print "$key:\t$val","\n";
#     }
#     print "\n";
# }

#my $gpml = wikipathways_api_client::getPathwayAs("gpml","WP528");
#my $filename = 'WP528.gpml';
#open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
#print $fh $gpml, "\n";
#close $fh;


# my @listXref = wikipathways_api_client::getXrefList('WP528','En');
# foreach my $ref (@listXref) {
#  	print $ref, "\n";
# }	

my $pw = "WP2223";
my @tags = 	wikipathways_api_client::getCurationTags($pw);

##Test: getCurationTags
#foreach my $tag (@tags) {
#		for my $key (keys %$tag) {
#			my $val = $tag->{$key};
#			if ($key eq "pathway") {
#				print "pathway info:\n";
#				for my $i (keys %$val)	{
#					my $info = $val->{$i};
#					print "\t$i:\t$info\n";	
#					}
#				}
#			else {
#				print "$key:\t$val\n";	
#				}
#			}
#			print "\n";
#	}

my $gpmlName = "test_create_path.gpml";
open(my $fh, '<:encoding(UTF-8)', $gpmlName)
or die "Could not open file '$gpmlfile' $!";

my $gpmlfile ="";
 while (my $row = <$fh>) {
	chomp $row;
	$gpmlfile = $gpmlfile. "$row\n";
}

my $user = "***";
my $password = "***";

my $auth = wikipathways_api_client::login($user, $password);
my $code = wikipathways_api_client::createPathway($gpmlfile, $auth, $user)
