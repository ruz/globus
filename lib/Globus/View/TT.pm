package Globus::View::TT;

use strict;
use warnings;
use parent 'Catalyst::View::TT';

use Template::Stash;

BEGIN {
	$Template::Stash::SCALAR_OPS->{ dump } =
	$Template::Stash::HASH_OPS->{ dump } =
	$Template::Stash::LIST_OPS->{ dump } = sub {
		require Data::Dumper;
		(map {s/\n$//;$_} Data::Dumper->new([$_[0]])->Indent(1)->Terse(1)->Purity(1)->Quotekeys(0)->Dump)[0];
	};
	
	$Template::Stash::SCALAR_OPS->{ uc } = sub { return uc $_[0] };
	$Template::Stash::SCALAR_OPS->{ lc } = sub { return lc $_[0] };
	$Template::Stash::SCALAR_OPS->{ ucfirst } = sub { return ucfirst lc $_[0] };
	$Template::Stash::SCALAR_OPS->{ lcfirst } = sub { return lcfirst uc $_[0] };
	
	$Template::Stash::SCALAR_OPS->{ is }   = sub { return $_[0] & $_[1] ? 1 : 0 };
	$Template::Stash::SCALAR_OPS->{ isnt } = sub { return !($_[0] & $_[1]) ? 1 : 0 };
	
	$Template::Stash::SCALAR_OPS->{ json } =
	$Template::Stash::HASH_OPS->{ json } =
	$Template::Stash::LIST_OPS->{ json } = sub { require JSON::XS; JSON::XS->can('encode_json') ? JSON::XS::encode_json($_[0]) : JSON::XS::to_json($_[0]); };
	
#	$Template::Stash::ROOT_OPS->{ ref } =
	$Template::Stash::SCALAR_OPS->{ ref } =
	$Template::Stash::HASH_OPS->{ ref } =
	$Template::Stash::LIST_OPS->{ ref } = sub { ref $_[0] };

	$Template::Stash::SCALAR_OPS->{ invoke } = sub {
		my $pk = shift;
		my $pf = join '/', split '::',$pk.'.pm';
		my $met = shift;
		#my $k; while (my @c = caller($k++)) { printf STDERR "$k. %s line %s\n", @c[1,2]; }
		eval { require $pf;1 } or return do {
			delete $INC{$pf};
			( my $e = $@ )=~ s{^([^\n]+)\n.*$}{$1}sg;
			$e .= sprintf ' at %s line %s',(caller(0))[1,2];
			return $ENV{DEBUG} ? "$pk require failed: $e" : '';
		} if $pk ne 'main';
		#printf STDERR "invoke $pk.$met\n";
		#$ENV{DEBUG} and return "$pk require failed: $@" or return if $pk ne 'main';
		return eval { $pk->$met(@_) } or $ENV{DEBUG} and return "$pk.invoke($met) failed: $@" or return;
	};
}


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
