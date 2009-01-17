use strict;
use warnings;

package Plagger::Plugin::Globus::Publish::Items;

use base qw(Plagger::Plugin);

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
        @create_args{qw(lang title body author published)} =
            ($lang, $entry->title, $entry->body, $entry->author, $entry->date);

        my $record = Globus::DB::Item->create( \%create_args );
    }

    $context->log(
        info => sprintf(
            "Added %d entries",
            $args->{feed}->count
        )
    );
}

1;
