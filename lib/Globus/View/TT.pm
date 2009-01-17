package Globus::View::TT;

use strict;
use warnings;
use parent 'Catalyst::View::TT';
__PACKAGE__->config({
    CATALYST_VAR => 'C',
    INCLUDE_PATH => [
        sowebface->path_to( 'root', 'src' ),
    ],
    DEFAULT_ENCODING    => 'utf-8',
    WRAPPER      => 'wrapper',
    ERROR        => 'error.tt2',
    TIMER        => 0,
    STASH        => Template::Stash->new(),
    FILTERS      => {
		    },
    %{sowebface->config->{TT}},
});

1;
