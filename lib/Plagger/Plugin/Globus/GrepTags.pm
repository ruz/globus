use strict;
use warnings;
use utf8;

package Plagger::Plugin::Globus::GrepTags;
use base qw( Plagger::Plugin );

sub register {
    my($self, $context) = @_;
    $context->register_hook(
        $self,
        'smartfeed.feed'  => \&feed,
    );
}

# TODO:
# add support for advanced filtering, for example:
# (catalyst AND perl) OR
#   (catalyst AND !adobe AND !ati AND !cisco AND !text:"adobe flash catalyst" AND !text:"flash catalyst")
# All this should be stored in a plugin's config

sub feed {
    my($self, $context, $args) = @_;

    $self->filter_entries( $args->{'feed'} );

    unless ($args->{feed}->count) {
        $context->log(debug => "Deleting " . $args->{feed}->title . " since it has 0 entries");
        $context->update->delete_feed($args->{feed})
    }
}

use Parse::BooleanLogic;

{ my $cache;
sub boolean_parser {
    my $self = shift;
    return $cache ||= Parse::BooleanLogic->new( operators => ['', 'OR'] );
} }

use Regexp::Common qw(delimited);
my $re_delim      = qr{$RE{delimited}{-delim=>qq{\'\"}}};
my $re_value      = qr{$re_delim|[^"']+};
my $re_cs_values  = qr{$re_value(?:,$re_value)*};


sub dq($) {
    my $s = $_[0];
    return $s unless $s =~ /^$re_delim$/o;
    substr( $s, 0, 1 ) = '';
    substr( $s, -1   ) = '';
    $s =~ s/\\(?=["'])//g;
    return $s;
}

our $operation_parser = sub {
    my $op = shift;
    if ( $op =~ /^(!?)(tag|author|content|title):($re_cs_values)$/o ) {
        my ($negative, $field, $value) = ($1, $2, $3);
        my @values = map dq $_, grep defined && length, split /,(?=$re_value|\z)/, $value;
        return { negative => $1, op => $field, values => \@values };
    } elsif ( $op =~ /^(has)(_no)?:(tag)$/ ) {
        return { negative => $2, op => $1, values => [$3] };
    } else {
        return { op => 'content', values => [$op] }
    }
};

our $boolean_solver = sub {
    my ($cond, $entry) = @_;

    use Data::Dumper;
    print Dumper( $cond );

    if ( $cond->{'op'} eq 'tag' ) {
        my $tags = $entry->tags;
        foreach my $et ( @{ $entry->tags } ) {
            return !$cond->{'negative'} if grep lc($_) eq lc($et), @{ $cond->{'values'} };
        }
        return $cond->{'negative'};
    } elsif ( $cond->{'has'} && $cond->{'values'}[0] eq 'tag' ) {
        return !$cond->{'negative'} if @{ $entry->tags };
        return $cond->{'negative'};
    } elsif ( $cond->{'op'} eq 'author' ) {
        die "TODO: not implemented";
    } elsif ( $cond->{'op'} eq 'title' || $cond->{'op'} eq 'content' ) {
        my $text = lc $entry->title_text;
        $text .= "\n". $entry->body_text
            if $cond->{'op'} eq 'content';

        foreach my $v ( @{ $cond->{'values'} } ) {
            return !$cond->{'negative'} if index($text, lc($v)) > 0;
        }
        return $cond->{'negative'};
    } else {
        warn "Don't know how to deal with '$cond', yet";
        return 1;
    }
};

sub filter_entries {
    my $self = shift;
    my $feed = shift;

    my $filter = $feed->meta->{'globus'}{'config'}{'filter'};
    return unless $filter;

    my $parser = $self->boolean_parser;
    my $tree = $parser->as_array( $filter, operand_cb => $operation_parser );

    foreach my $entry ( $feed->entries ) {
        next if $parser->solve( $tree, $boolean_solver, $entry );

        $self->log(
            debug => "Deleting " . $entry->permalink
            ." since it doesn't match filter '$filter'"
        );

        $feed->delete_entry($entry);
    }
}

1;
