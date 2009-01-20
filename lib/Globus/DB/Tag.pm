package Globus::DB::Tag;

use strict;
use warnings;

use base 'DBIx::Class';
__PACKAGE__->load_components(qw/UTF8Columns Core/);
__PACKAGE__->table("tags");
__PACKAGE__->add_columns(
  id => { data_type => "INTEGER", default_value => undef, is_nullable => 0, is_auto_increment => 1},
  en => { data_type => "VARCHAR", default_value => undef, is_nullable => 0, size => 255, },
  ru => { data_type => "VARCHAR", default_value => undef, is_nullable => 1, size => 255, },
  klingon => { data_type => "VARCHAR", default_value => undef, is_nullable => 1, size => 255, },
);

__PACKAGE__->utf8_columns(qw/en ru klingon/);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("tag_en_Idx", ["en"]);
__PACKAGE__->add_unique_constraint("tag_ru_Idx", ["ru"]);

__PACKAGE__->has_many('item_tag', 'Globus::DB::ItemTag', 'tag');
__PACKAGE__->many_to_many(items => item_tag => 'item');

use Text::Unidecode;

sub new {
    my ( $class, $attrs ) = @_;

    unless ( defined $attrs->{'en'} && length $attrs->{'en'} ) {
        my ($from) = grep defined && length, map $attrs->{$_}, qw(ru klingon);
        $attrs->{'en'} = unidecode( $from );
    }

    return $class->next::method($attrs);
}

1;
