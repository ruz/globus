package Globus::View::TT;

use strict;
use warnings;
use parent 'Catalyst::View::TT';
use Globus::View::TT::Methods;
__PACKAGE__->config({
    CATALYST_VAR => 'C',
    INCLUDE_PATH => [
        Globus->path_to( 'root', 'src' ),
    ],
    DEFAULT_ENCODING    => 'utf-8',
    WRAPPER      => 'wrapper',
    ERROR        => 'error.tt',
    TIMER        => 0,
    FILTERS      => {
		    },
    %{Globus->config->{TT}||{}},
});

1;
