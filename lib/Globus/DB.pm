package Globus::DB;

use strict;
use warnings;

use base 'DBIx::Class::Schema';
__PACKAGE__->load_classes;

my $cfg=YAML::LoadFile("globus.yml");

sub our_connect_handler {
    return sub {
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
    };
}

1;
