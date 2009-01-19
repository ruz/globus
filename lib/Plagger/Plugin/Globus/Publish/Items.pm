use strict;
use warnings;

package Plagger::Plugin::Globus::Publish::Items;
use base qw(Plagger::Plugin);

use Globus::DB;
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
    my $feed_lang = $feed->language || 'ru';
    foreach my $entry ($args->{feed}->entries) {
        my $link = $entry->permalink;
        my $title = $entry->title;
        my $lang = $entry->language || $feed_lang;
        print "$link $lang\n";
        my $tags = $entry->tags;

        my $item = $schema->resultset('Item')->find_or_create( {
            lang => $lang,
            source => 'test',
            link => $link,
            title => $entry->title,
            content => $entry->body,
            author => $entry->author || 'test',
            date => $entry->date,
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
