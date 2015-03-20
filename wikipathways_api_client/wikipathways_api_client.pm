#!/usr/bin/env perl -w
use strict;
use warnings;

# http://search.cpan.org/~mcrawfor/REST-Client/lib/REST/Client.pm
# Example install using cpanm:
#   sudo cpanm -i REST::Client

use REST::Client;
use XML::LibXML;
use JSON;

package wikipathways_api_client;

# Set the request parameters
my $host = 'http://webservice.wikipathways.org/';
my $client = REST::Client->new(host => $host);

sub listOrganisms {
	$client->GET("listOrganisms");
	my $parser = XML::LibXML->new();
	$parser->keep_blanks(0);  
	my $doc = $parser->load_xml(string => $client->responseContent());
	$doc->setEncoding('UTF-8');
	my $root = $doc->documentElement();

	my @organisms = $root->childNodes();
	my @list;
	foreach my $species (@organisms) {
		push(@list, $species->firstChild->data);
	}	
	return @list;
}
sub listPathways {
	my $organism = $_[0];
	my $method = 'listPathways' ;
	$client->GET("$method?organism=$organism");

	my $parser = XML::LibXML->new();
	$parser->keep_blanks(0);  
	my $doc = $parser->load_xml(string => $client->responseContent());
	$doc->setEncoding('UTF-8');
	my $root = $doc->documentElement();
	my @pathwayInfo = $root->childNodes();
	my @list;
	foreach my $organisms (@pathwayInfo) {
		my %pathway;
		foreach my $info ($organisms->childNodes()){
			$pathway{$info->localname()} = $info->textContent();
		}
		push(@list, \%pathway);
	}
	return @list;
}

sub getPathway{
	my $pathway_id  = $_[0];
	my $revision = $_[1];
	$revision ||= '';	
	my $method = 'getPathway' ;
	$client->GET("$method?pwId=$pathway_id&revision=$revision&format=json");

	my @records = JSON->new->utf8->decode($client->responseContent())->{'pathway'};
	my %hash;
	for my $record (@records) {
		for my $key (keys(%$record)) {	
			$hash{$key} = $record->{$key};
		}
	}
	return %hash;
}

sub getPathwayInfo {
	my $pathway_id  = $_[0];
	my $method = 'getPathwayInfo' ;
	$client->GET("$method?pwId=$pathway_id ");
	my $parser = XML::LibXML->new();
	$parser->keep_blanks(0);
	my $doc = $parser->parse_string($client->responseContent());
	$doc->setEncoding('UTF-8');
	my $root = $doc->documentElement();
	my @pathwayInfo = $root->childNodes();

	my %hash;
	foreach my $pathwayInfo (@pathwayInfo) {
		foreach my $info ($pathwayInfo->childNodes()){
			$hash{$info->localname()} = $info->textContent();
		}
	}
	return %hash;
}


sub getPathwayHistory {
	my $pathway_id  = $_[0];
	my $timestamp = $_[1]; #20070522221730 yyyymmddhhmmss
	$timestamp ||= '';
	my $method = 'getPathwayHistory' ;
	$client->GET("$method?pwId=$pathway_id&timestamp=$timestamp");

	my $parser = XML::LibXML->new();
	$parser->keep_blanks(0);  
	my $doc = $parser->load_xml(string => $client->responseContent());
	$doc->setEncoding('UTF-8');
	my $root = $doc->documentElement();
	my @pathwayInfo = $root->childNodes();

	my %hash;
	my @list;


	foreach my $pathwayInfo (@pathwayInfo) {
		foreach my $info ($pathwayInfo->childNodes()){	  
			if ($info->firstChild()->hasChildNodes()){
				my %pathway;
				foreach my $hitory ($info->childNodes()){
					$pathway{$hitory->localname()} = $hitory->textContent();
				}
				push(@list, \%pathway);
			}
			else{
				$hash{$info->localname()} = $info->textContent();
			}	      
		}
	}
	$hash{"history"} = \@list;
	return %hash;
}

sub getRecentChanges{
	my $timestamp = $_[0];
	$timestamp ||= '';
	my $method = 'getRecentChanges' ;
	$client->GET("$method?timestamp=$timestamp");

	my $parser = XML::LibXML->new();
	$parser->keep_blanks(0);  
	my $doc = $parser->load_xml(string => $client->responseContent());
	$doc->setEncoding('UTF-8');
	my $root = $doc->documentElement();
	my @pathwayInfo = $root->childNodes();

	my @list;
	foreach my $organisms (@pathwayInfo) {
		my %pathway;
		foreach my $info ($organisms->childNodes()){
			$pathway{$info->localname()} = $info->textContent();
		}
		push(@list, \%pathway);
	}
	return @list;
}


sub getPathwayAs{
	my $fileType= $_[0];
	my $pathway_id = $_[1];
	my $revision = $_[2];
	$revision ||= '';
	my $method = 'getPathwayAs' ;
	$client->GET("$method?pwId=$pathway_id&fileType=$fileType&revision=$revision&format=json");
	my $decoded = JSON->new->utf8->decode($client->responseContent());
	return $decoded->{'data'};
}

sub getXrefList {	
	my $pathway_id = $_[0];
	my $code= $_[1];
	$client->GET("getXrefList?pwId=$pathway_id&code=$code");
	my $parser = XML::LibXML->new();
	$parser->keep_blanks(0);  
	my $doc = $parser->load_xml(string => $client->responseContent());
	$doc->setEncoding('UTF-8');
	my $root = $doc->documentElement();


	my @organisms = $root->childNodes();
	my @list;
	foreach my $species (@organisms) {
		push(@list, $species->firstChild->data);
	}	
	return @list;
}

sub getCurationTags {
	my $pathway_id = $_[0];
	$client->GET("getCurationTags?pwId=$pathway_id");
	my $parser = XML::LibXML->new();
	$parser->keep_blanks(0);
	my $doc = $parser->load_xml(string => $client->responseContent());
	$doc->setEncoding('UTF-8');
	my $root = $doc->documentElement();
	my @tags = $root->childNodes();
	
	my @taglist; 
	
	foreach my $tag (@tags) {
		my %hash;
		foreach my $info ($tag->childNodes()){
			if ($info->textContent()){	#Some items are blank
				if ($info->firstChild->hasChildNodes()){  
					my %pathway;
					foreach my $i ($info->childNodes()){
						$pathway{$i->localname()} = $i->textContent();
					}
					$hash{"pathway"} = \%pathway;
				}
				else {
					$hash{$info->localname()} = $info->textContent();
					}	
				}
				else {
				$hash{$info->localname()} = $info->textContent();  
					}	
			}
		push(@taglist, \%hash);	
		}	
		return @taglist;
}

sub login{
		my $user = $_[0];
        my $password= $_[1];

		$client->GET("login?name=$user&pass=$password&format=xml");
		my $parser = XML::LibXML->new();
		$parser->keep_blanks(0); 
		my $doc = $parser->load_xml(string => $client->responseContent());
		$doc->setEncoding('UTF-8');
		my $root = $doc->documentElement();
		my $authcode = $root->firstChild->textContent();
		return $authcode;
}

sub createPathway {
        my $gpml = $_[0];
        my $authcode= $_[1];
        my $username = $_[2];

		my $headers = {'Content-type' => 'application/x-www-form-urlencoded'};
		my $params = $client->buildQuery({
			gpml => $gpml,
			auth => $authcode,
			username => $username            
		});
		$params =~ s/\?//; # buildQuery() prepends a '?' so we strip that out
		$client->POST('createPathway', $params , $headers);

		my $parser = XML::LibXML->new();
		$parser->keep_blanks(0); 
		my $doc = $parser->load_xml(string => $client->responseContent());
		$doc->setEncoding('UTF-8');
		my $root = $doc->documentElement();
		print $root, "\n";
        return $root,;
}


1;
