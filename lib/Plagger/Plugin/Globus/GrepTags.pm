use strict;
use warnings;
use utf8;

package Plagger::Plugin::Globus::GrepTags;
use base qw( Plagger::Plugin );

use Parse::BooleanLogic '0.06';
use Regexp::Common qw(delimited);

sub register {
    my($self, $context) = @_;
    $context->register_hook(
        $self,
        'smartfeed.feed'  => \&feed,
    );
}

sub feed {
    my($self, $context, $args) = @_;

    $self->filter_entries( $args->{'feed'} );

    unless ($args->{feed}->count) {
        $context->log(debug => "Deleting " . $args->{feed}->title . " since it has 0 entries");
        $context->update->delete_feed($args->{feed})
    }
}


sub filter_entries {
    my $self = shift;
    my $feed = shift;

    my $filter = $feed->meta->{'globus'}{'config'}{'filter'};
    return unless $filter;

    my $parser = $self->parser;
    my $tree = $self->parse_filter( $filter );
    my $solver = $self->filter_solver;

    foreach my $entry ( $feed->entries ) {
        next if $parser->solve( $tree, $solver, $entry );

        $self->log(
            debug => "Deleting " . $entry->permalink
            ." since it doesn't match filter '$filter'"
        );

        $feed->delete_entry($entry);
    }
}

{ my %cache;
sub parse_filter {
    my $self = shift;
    my $string = shift;

    return $cache{$string} ||= $self->parser->as_array(
        $string, operand_cb => $self->condition_parser
    );
} }

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

{ my $cache;
sub parser {
    my $self = shift;
    return $cache ||= Parse::BooleanLogic->new( operators => ['', 'OR'] );
} }

sub filter_solver {
    return sub {
        my ($cond, $entry) = @_;

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
}

sub condition_parser {
    return sub {
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
}

1;
