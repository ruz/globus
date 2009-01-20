package Globus::DB::ItemTag;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("items_tags");
__PACKAGE__->add_columns(
  item => { data_type => "INTEGER", default_value => undef, is_nullable => 0},
  tag => { data_type => "INTEGER", default_value => undef, is_nullable => 0},
);

__PACKAGE__->set_primary_key(qw(item tag));

__PACKAGE__->belongs_to("item", "Globus::DB::Item", { 'foreign.id' => 'self.item' });
__PACKAGE__->belongs_to("tag", "Globus::DB::Tag", { 'foreign.id' => 'self.tag' });

1;
