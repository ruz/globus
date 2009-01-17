package Globus::Controller::Root;

use strict;
use warnings;
use parent 'Catalyst::Controller';

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config->{namespace} = '';

=head1 NAME

Globus::Controller::Root - Root Controller for Globus

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=cut

=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
	$c->stash->{items} = [ $c->model('DB::Item')->all ];
    $c->stash->{template} = 'index.tt';
}

sub default :Path {
    my ( $self, $c ) = @_;
    $c->detach( 'Root', 'items', [ $c->parse_item_filters( $c->req->path ) ] ) if ( $c->req->path =~ /^items(?:\/|$)/ );
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

sub items :Path {
	my ($self,$c,$args) = @_;
	$c->stash->{items} = [ $c->model('DB::Item')->all ];
    $c->stash->{template} = 'index.tt';
}

sub item :Regex('^item\/(\w+)\/(\d{4}-\d{2}-\d{2})') {
	my ($self,$c,$args) = @_;
    my ($keyword, $date) = @{ $c->req->captures }; 
    my $item = $c->model('DB::Item')->single( {date    => $date,
                                               keyword => $keyword,} );
	if ($item) {
        $c->stash->{template} = 'item.tt';
        $c->stash->{item} = $item;
    }
    else {
        $c->stash->{template} = 'item_not_found.tt';
    }
    #use Data::Dumper;
    #$c->response->body( Dumper($args) );
}

sub test :Local :Args(0) {
    my ( $self, $c ) = @_;
    my $s=$c->{stash};
    my $schema=$c->model('DB'); #how to optain DB schema in controller
    $s->{template}='test.tt';
}


=head2 end

Attempt to render a view, if needed.

=cut 

sub end : ActionClass('RenderView') {}

=head1 AUTHOR

Ruslan Zakirov

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
