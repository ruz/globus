use strict;
use warnings;

package Plagger::Plugin::Globus::Publish::Items;

use base qw(Plagger::Plugin);

use Globus::DB;
use DateTime::Format::ISO8601;
use Data::Dumper;

sub register {
    my ($self, $context) = @_;
    $context->register_hook(
        $self,
        'publish.feed' => \&feed,
    );
}

sub feed {
    my ($self, $context, $args) = @_;

    my $schema = Globus::DB->connect( Globus::DB->our_connect_handler );

    my $lang = $self->conf->{lang} || 'en';
    foreach my $entry ($args->{feed}->entries) {

        $schema->populate('Item' =>  [
            [qw(lang keyword source link title content author date)],
            [$lang, 'test', 'test', 'test', $entry->title, $entry->body, $entry->author || 'test', DateTime::Format::ISO8601->parse_datetime( $entry->date ) ],
        ]);
        last;
    }

    $context->log(
        info => sprintf(
            "Added %d entries",
            $args->{feed}->count
        )
    );
}

1;
