package Globus::Model::DB;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
	schema_class => 'Globus::DB',
# ruz: most probably it's not required as we have this in our config
#		connect_info => [sub {
#			my ($dsn, $user, $pass) = @{Globus->config->{DB}};
#			my $dbh=DBI->connect($dsn, $user, $pass,{ autocommit=>1 });
#			if ( $dsn =~ /SQLite/ ) {
#				$dbh->{unicode}=1;
#			} elsif ( $dsn =~ /mysql/ ) {
#				$dbh->{mysql_enable_utf8}=1;
#				$dbh->do('set names utf8;');
#				$dbh->do('set character set utf8;');
#			}
#			return $dbh;
#		} ],
);


1;
