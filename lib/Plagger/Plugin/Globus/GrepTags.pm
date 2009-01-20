use strict;
use warnings;
use utf8;

package Plagger::Plugin::Globus::GrepTags;
use base qw( Plagger::Plugin );

sub register {
    my($self, $context) = @_;
    $context->register_hook(
        $self,
        'smartfeed.feed'  => \&feed,
    );
}

sub feed {
    my($self, $context, $args) = @_;

    for my $entry ($args->{feed}->entries) {
        my $tags = $entry->tags;
        next unless @$tags;
        next if grep /(?:perl|перл)/i, @$tags;

        $context->log(debug => "Deleting " . $entry->permalink . " since it has tags (". join(', ', @$tags) . ") non of which is perl");

        $args->{feed}->delete_entry($entry);
    }

    unless ($args->{feed}->count) {
        $context->log(debug => "Deleting " . $args->{feed}->title . " since it has 0 entries");
        $context->update->delete_feed($args->{feed})
    }
}

1;

