use strict;
use warnings;

package Plagger::Plugin::Globus::Publish::Items;

use base qw(Plagger::Plugin);

use Globus::DB;
our $schema = Globus::DB->connect;
use DateTime::Format::ISO8601;
use Data::Dumper;
print Dumper($schema);
print Dumper($schema->resultset('Item')->all);

use Globus::DB::Item;

sub register {
    my ($self, $context) = @_;
    $context->register_hook(
        $self,
        'publish.feed' => \&feed,
    );
}

sub feed {
    my ($self, $context, $args) = @_;

    my $lang = $self->conf->{lang} || 'en';
    foreach my $entry ($args->{feed}->entries) {

        my %create_args;
        @create_args{qw(lang title content author date)} =
            ($lang, $entry->title, $entry->body, $entry->author, $entry->date);

        $create_args{date} = DateTime::Format::ISO8601->parse_datetime( $create_args{date} );
        print Dumper($create_args{date}) . "\n". $create_args{date} . "\n";
        my $record = Globus::DB->resultset('Item')->create( \%create_args );
    }

    $context->log(
        info => sprintf(
            "Added %d entries",
            $args->{feed}->count
        )
    );
}

1;
