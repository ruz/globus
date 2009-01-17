use strict;
use warnings;

package Plagger::Plugin::Globus::Publish::Items;

use base qw(Plagger::Plugin);

use Globus::DB;
use DateTime::Format::ISO8601;
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

    my $lang = $self->conf->{lang} || 'en';
    foreach my $entry ($args->{feed}->entries) {
        my $link = $entry->permalink;
        my $title = $entry->title;
        my $date = DateTime::Format::ISO8601->parse_datetime( $entry->date );
        use Text::Unidecode;
        my $keyword = $date->ymd('_') .' '. unidecode( $title );
        $keyword =~ s/\s+/_/;

        $schema->resultset('Item')->create( {
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
