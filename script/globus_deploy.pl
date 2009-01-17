#!/usr/bin/perl

use strict;
use lib "lib";
use Data::Dumper;
use YAML qw(Dump Bless);

use Globus::DB;
my $cfg=YAML::LoadFile("Globus.yml");


my $schema=Globus::DB->connect(sub {
			     my $dbh=DBI->connect(@{$cfg->{DB}},{
								autocommit=>1
							       });
			     $dbh->{mysql_enable_utf8}=1;
			     $dbh->do('set names utf8;');
			     $dbh->do('set character set utf8;');
			     return $dbh;
			 });

$schema->deploy({ add_drop_table => 1, },'');
