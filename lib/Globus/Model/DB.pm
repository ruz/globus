package Globus::Model::DB;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'Globus::DB',
                    connect_info => [sub {
                                         my $dbh=DBI->connect(@{Globus->config->{DB}},{
                                                                                     autocommit=>1
                                                                                    });
                                         $dbh->{mysql_enable_utf8}=1;
                                         $dbh->do('set names utf8;');
                                         $dbh->do('set character set utf8;');
                                         return $dbh;
                                     }],
);


1;
