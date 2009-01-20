use strict;
use warnings;

package Plagger::Plugin::Globus::Quirks;
use base qw(Plagger::Plugin);

use Data::Dumper;

sub register {
    my ($self, $context) = @_;
    $context->register_hook(
        $self,
        'aggregator.entry.fixup' => \&fixup,
    );
}

sub fixup {
    my ($self, $context, $args) = @_;
    my ($feed, $entry, $ofeed, $oentry) = @{$args}{'feed', 'entry', 'orig_feed', 'orig_entry'};

    # normalize tags to array reference
    {
        my $tags = $entry->tags;
        $tags ||= [];
        $tags = [$tags] if ref($tags) ne 'ARRAY';
        $entry->tags( $tags );
    }

    # bessarabov's feed has Uncategorized tag on all entries
    # XXX: check with Ivan, may be it's something special about
    # his repository
    if ( $feed->url eq 'http://blog.bessarabov.ru/feed/' ) {
        $context->log( debug => 'quirking entry in '. $feed->url );

        $entry->tags( [ grep lc($_) ne 'uncategorized', @{ $entry->tags } ] );
    }
}

1;
