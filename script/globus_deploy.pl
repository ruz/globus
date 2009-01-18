#!/usr/bin/perl -w

use strict;
use ex::lib "../lib";
use Data::Dumper;
use YAML qw(Dump Bless);

use Globus::DB;

my $schema=Globus::DB->connect( Globus::DB->our_connect_handler );
$schema->deploy({ add_drop_table => 1, },'');

$schema->populate( Feed => [
    [qw(link)],
    ['http://perl6.ru/rss/'],
    ['http://dr-japh.livejournal.com/data/rss'],
    ['http://feeds.delicious.com/v2/rss/tag/russian+perl?count=15'],
]);
