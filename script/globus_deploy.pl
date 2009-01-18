#!/usr/bin/perl -w

use strict;
use ex::lib "../lib";
use Data::Dumper;
use YAML qw(Dump Bless);

use Globus::DB;

my $schema=Globus::DB->connect( Globus::DB->our_connect_handler );

$schema->deploy({ add_drop_table => 1, },'');
