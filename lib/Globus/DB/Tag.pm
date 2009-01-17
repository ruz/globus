package Globus::DB::Tag;

use strict;
use warnings;

use base 'DBIx::Class';
__PACKAGE__->load_components(qw/InflateColumn::DateTime UTF8Columns Core/);
__PACKAGE__->table("tag");
__PACKAGE__->add_columns(
  id => { data_type => "INTEGER", default_value => undef, is_nullable => 0, is_auto_increment => 1},
  en => { data_type => "VARCHAR", default_value => undef, is_nullable => 0, size => 255, },
  ru => { data_type => "VARCHAR", default_value => undef, is_nullable => 0, size => 255, },
  klingon => { data_type => "VARCHAR", default_value => undef, is_nullable => 0, size => 255, },
);

__PACKAGE__->utf8_columns(qw/en ru klingon/);
__PACKAGE__->set_primary_key("id");

__PACKAGE__->has_many('doctags', 'Globus::DB::ItemTag', 'tag');
__PACKAGE__->many_to_many(items => doctags => 'item');
1;
