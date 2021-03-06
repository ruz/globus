package Globus::DB::Feed;

use strict;
use warnings;
use base 'DBIx::Class';
__PACKAGE__->load_components(qw/UTF8Columns Core/);
__PACKAGE__->table("feeds");
__PACKAGE__->add_columns(
  id => { data_type => "INTEGER", default_value => undef, is_nullable => 0, is_auto_increment => 1},
  link => { data_type => "VARCHAR", default_value => undef, is_nullable => 0, size => 255, },
  title => { data_type => "VARCHAR", default_value => undef, is_nullable => 1, size => 255, },
  config => { data_type => "TEXT", default_value => undef, is_nullable => 1, },

);

__PACKAGE__->utf8_columns(qw/title/);
__PACKAGE__->set_primary_key("id");

use YAML qw();
__PACKAGE__->inflate_column(
    config => {
        'inflate'   => sub { YAML::Load($_[0]) },
        'deflate'   => sub { YAML::Dump($_[0]) },
    }
);

1;

