package Globus::Model::DB;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

use Globus::DB;

__PACKAGE__->config(
	schema_class => 'Globus::DB',
		connect_info => [Globus::DB->our_connect_handler],
);


1;
