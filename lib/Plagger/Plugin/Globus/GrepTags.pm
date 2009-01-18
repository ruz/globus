package Plagger::Plugin::Globus::GrepTags;

use strict;

use strict;
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
        $args->{feed}->delete_entry($entry)
            if exists $entry->{tags} and !grep { /(?:perl)/i } @{ $entry->{tags} };
    }

    if ($args->{feed}->count == 0) {
        $context->log(debug => "Deleting " . $args->{feed}->title . " since it has 0 entries");
        $context->update->delete_feed($args->{feed})
    }

}

1;

