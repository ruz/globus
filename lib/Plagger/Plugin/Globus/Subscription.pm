=head1 NAME

Plagger::Plugin::Globus::Subscription - Subscriptions from Globus project's DB

=head1 SYNOPSIS

    - module: Globus::Subscription

=head1 DESCRIPTION

This plugin fetches list of feeds from our DB.

=head1 TODO

=over 4

=item add frequencies and last fetched to avoid fetching rarely updated feeds

=back

=cut

use strict;
use warnings;

package Plagger::Plugin::Globus::Subscription;
use base qw(Plagger::Plugin);

use Encode;
use Globus::DB;

sub register {
    my($self, $context) = @_;

    $context->register_hook(
        $self,
        'subscription.load' => $self->can('load'),
    );
}

sub load {
    my($self, $context) = @_;

    my $schema = Globus::DB->connect( Globus::DB->our_connect_handler );

    for my $record ( $schema->resultset('Feed')->all ) {
        my $feed = Plagger::Feed->new;
        $feed->url($record->link)
            or $context->error("Feed URL is missing");
        #$feed->title($record->title) if $record->title;
        $context->subscription->add($feed);
    }
}

=head1 AUTHOR

Ruslan Zakirov

=cut

1;
