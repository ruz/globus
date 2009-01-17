use strict;
use warnings;

package Plagger::Plugin::Globus::Publish::Items;

use base qw(Plagger::Plugin);

use Globus::DB;
use DateTime::Format::ISO8601;
use Text::Unidecode;

use Data::Dumper;

sub register {
    my ($self, $context) = @_;
    $context->register_hook(
        $self,
        'publish.feed' => \&feed,
    );
}

sub feed {
    my ($self, $context, $args) = @_;

    my $schema = Globus::DB->connect( Globus::DB->our_connect_handler );

    my $feed = $args->{feed};
    my $feed_lang = $feed->language;
    foreach my $entry ($args->{feed}->entries) {
        my $link = $entry->permalink;
        my $title = $entry->title;
        my $date = DateTime::Format::ISO8601->parse_datetime( $entry->date );
        my $keyword = $date->ymd('_') .' '. unidecode( $title );
        $keyword =~ s/\s+/_/;

        my $lang = $entry->language || $feed_lang;
        print "$link $lang";
        my $tags = $entry->tags;

        #print Dumper( $tags );

        my $item = $schema->resultset('Item')->find_or_create( {
            lang => $lang,
            keyword => $keyword,
            source => 'test',
            link => $link,
            title => $entry->title,
            content => $entry->body,
            author => $entry->author || 'test',
            date => $date,
        });

    }

    $context->log(
        info => sprintf(
            "Added %d entries",
            $args->{feed}->count
        )
    );
}

1;
