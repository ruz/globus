#!/usr/bin/perl

use strict;
use ex::lib "../lib";
use Data::Dumper;
use YAML qw(Dump Bless);

use Globus::DB;
my $cfg=YAML::LoadFile("$INC[0]/../globus.yml");

my $schema=Globus::DB->connect;

$schema->deploy({ add_drop_table => 1, },'');
