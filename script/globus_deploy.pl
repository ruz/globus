#!/usr/bin/perl

use strict;
use ex::lib "../lib";
use Data::Dumper;
use YAML qw(Dump Bless);

use Globus::DB;
my $cfg=YAML::LoadFile("$INC[0]/../Globus.yml");

my $schema=Globus::DB->connect(sub {
                             my ($dsn, $user, $pass) = @{$cfg->{DB}};
			     my $dbh=DBI->connect($dsn, $user, $pass,{
								autocommit=>1
							       });
                             if ( $dsn =~ /SQLite/ ) {
                                 $dbh->{unicode}=1;
                             } elsif ( $dsn =~ /mysql/ ) {
                                 $dbh->{mysql_enable_utf8}=1;
                                 $dbh->do('set names utf8;');
                                 $dbh->do('set character set utf8;');
                             }
			     return $dbh;
			 });

$schema->deploy({ add_drop_table => 1, },'');
