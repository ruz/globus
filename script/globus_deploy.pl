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
    ['http://moscow.pm.org/rss/'],
    ['http://kostenko.name/feed/'],
    ['http://blog.bessarabov.ru/feed/'],

#http://www.perl-blog.de/
#http://blog.seo-p.ru/
#http://perl.blogit.ru/
#http://blog.gravatar.com
#http://use.perl.org/~andy.sh/journal/
#http://use.perl.org
#http://blog.yandex.ru/search.rss?text=%D1%85%D0%B0%D0%BA%D0%BC%D0%B8%D1%82 
#http://community.livejournal.com/ru_perl
]);
