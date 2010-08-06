#!/usr/bin/perl

=pod

Demonstrate how to write out JSON or XML to a file
using handlers. XML is the default if no argument is specified.

Please keep in mind this example only generates a partial list of
titles from Lovefilm. If you want a full list you will have to
extend it by paging.

=cut

use strict;
use warnings;
use WWW::Lovefilm::API;

my $type        = defined($ARGV[0]) ? $ARGV[0] : 'xml';
my $filename    = 'catalog.' . $type;
my $return_type = $type eq 'json' ? '.json' : '';

my %vars = do('vars.inc');
my $lovefilm = WWW::Lovefilm::API->new({
  consumer_key    => $vars{consumer_key},
  consumer_secret => $vars{consumer_secret},
});

$lovefilm->ua->add_handler( response_header => sub {
  my($response, $ua, $h) = @_;
  $response->{default_add_content} = 0;
  open OUTPUT, '>', $filename or die $!;
} );
$lovefilm->ua->add_handler( response_data => sub {
  my($response, $ua, $h, $data) = @_;
  print OUTPUT $data or die $!;
  return 1;
} );
$lovefilm->ua->add_handler( response_done => sub {
  my($response, $ua, $h) = @_;
  close OUTPUT or die $!;
} );

$lovefilm->REST->Catalog->Title($return_type);
$lovefilm->Get(
    items_per_page => 250, # max is 250 as of 2010-08-05
    expand => 'actors,directors,synopsis,languages,collections,histogram,artworks',
);

