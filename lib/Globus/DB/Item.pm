package Globus::DB::Item;

use strict;
use warnings;

use base 'DBIx::Class';
__PACKAGE__->load_components(qw/InflateColumn::DateTime UTF8Columns Core/);
__PACKAGE__->table("items");
__PACKAGE__->add_columns(
  id => { data_type => "INTEGER", default_value => undef, is_nullable => 0, is_auto_increment => 1},
  keyword => { data_type => "VARCHAR", default_value => undef, is_nullable => 0, size => 255, },
  link => { data_type => "VARCHAR", default_value => undef, is_nullable => 0, size => 255, },
  date => { data_type => "DATETIME", default_value => '1970-1-1 0:0:0', is_nullable => 1 },
  title => { data_type => "VARCHAR", default_value => undef, is_nullable => 0, size => 255, },
  content => { data_type => "TEXT", default_value => undef, is_nullable => 1,},
  author => { data_type => "VARCHAR", default_value => undef, is_nullable => 0, size => 255, },
  source => { data_type => "VARCHAR", default_value => undef, is_nullable => 0, size => 255, },
  lang => { data_type => "VARCHAR", default_value => undef, is_nullable => 0, size => 255, },
);

__PACKAGE__->utf8_columns(qw/keyword title content author source/);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("item_keyword_Idx", ["keyword"]);

sub sqlt_deploy_hook {
    my ($self, $table) = @_;
    $table->add_index(name => 'item_date_Idx', fields => ['date']);
    $table->add_index(name => 'item_lang_Idx', fields => ['lang']);
    $table->extra('mysql_charset', '=utf8');
}

__PACKAGE__->has_many(item_tag => "Globus::DB::ItemTag", 'item');
__PACKAGE__->many_to_many(tags => itemtags => 'tag');

sub REF {
    my $self=shift;
    return ref $self;
};
1;
