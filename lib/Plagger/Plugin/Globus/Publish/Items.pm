use strict;
use warnings;
use utf8;

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

    my $counter = 0;

    my $feed = $args->{feed};
    my $feed_lang = $feed->language || '';
    foreach my $entry ( $feed->entries ) {
        my $link = $entry->permalink;
        my $title = $entry->title;
        my $lang = $entry->language || $feed_lang;

        # TODO: we generate keyword in Item::new, however it's
        # the only unique field in items besides id, find_or_create
        # fails to find correct record even if it already exist
        my $item = $schema->resultset('Item')->find_or_create( {
            link    => $link,
            date    => $entry->date,
            author  => $entry->author || 'test',
            title   => $entry->title,
            content => $entry->body,
            lang    => $lang,
            source  => 'test',
        });

        my $tags = $entry->tags;
        foreach my $tag ( map "$_", @$tags ) {
            # TODO: use lame detection while we don't have better solution
            my $tag_lang = ($tag =~ /[а-я]/i? 'ru' : 'en');

            # XXX: in theory the following should just work, but it doesn't
            # $item->find_or_create_related('tags', { $tag_lang => $tag } );
            my $tag_rec = $schema->resultset('Tag')->find_or_create( {
                $tag_lang => $tag
            });

            my $item_tag_rec = $schema->resultset('ItemTag')->find_or_create( {
                item => $item->id, tag => $tag_rec->id
            });
        }

        $counter++;
    }

    $context->log(
        info => sprintf(
            "Added %d entries out of %d",
            $counter, $args->{feed}->count
        )
    );
}

1;
