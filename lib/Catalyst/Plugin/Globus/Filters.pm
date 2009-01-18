package Catalyst::Plugin::Globus::Filters;
# -*- mode: cperl; encoding: utf8 -*-
use utf8;
use warnings;
use strict;

sub parse_item_filters {
    my ( $self, $path ) = @_;
    my @segments = grep { $_ } split(/\//, $path);
    my %args = ( format => 'web' );
    for my $seg ( @segments ) {
        # дата указана по году
        if ( $seg =~ m/^(\d{4})$/ ) {
            push @{$args{'date'}}, {
                year => $1,
            };
        }
        # дата указана по году и месяцу
        if ( $seg =~ m/^(\d{4})-(\d{2})$/ ) {
            push @{$args{'date'}}, {
                year => $1,
                month => $2,
            };
        }
        # дата указанеа по году, месяцу и дню
        if ( $seg =~ m/^(\d{4})-(\d{1,2})-(\d{1,2})$/ ) {
            push @{$args{'date'}}, {
                year => $1,
                month => $2,
                day => $3,
            };
        }
        # указан тег или теги через запятую
        if ( $seg =~ m/^tag=(.*)$/ ) {
            push @{$args{'tag'}}, split(/\,/, $1);
        }
        # указан автор или авторы через запятую
        if ( $seg =~ m/^author=(.*)$/ ) {
            push @{$args{'author'}}, split(/\,/, $1);
        }
        # указан формат
        if ( $seg = $segments[$#segments] and $seg =~ /^(:?html|rss|atom)$/ ) {
            $args{'format'} = $1;
        }
    }
    return \%args;
}

1;
