package Catalyst::Plugin::Globus::Pager;

use warnings;
use strict;

sub create_pager {
    my $self = shift;
    my %args = @_;

    my $pager = {};
    $pager->{'page'}->{'now'}      = $args{'page_now'};
    $pager->{'page'}->{'size'}     = $args{'page_size'} || 10;
    $pager->{'page'}->{'count'} =
      int( ( $args{'events_count'} - 1 ) / $args{'page_size'} + 1 );

    $pager->{'events'}->{'offset'} = ( $pager->{'page'}->{'now'} - 1 ) * 10;

    # using example
    # $c->model('DB::Item')->search()->slice(
    #     $c->stash->{'pager'}->{'events'}->{'offset'},
    #     $c->stash->{'pager'}->{'events'}->{'offset'} +
    #       $c->stash->{'pager'}->{'page'}->{'size'}
    #   )

    return $pager;

}

1;
