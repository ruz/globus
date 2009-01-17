package Globus::Controller::Root;

use strict;
use warnings;
use parent 'Catalyst::Controller';
use DateTime;

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
	
	my $search_items;
	my $search_tags;
	my $rs;
	if ($args->{tag}) {
		$search_tags = { 'en' => [  'a','b' ] };
		$rs = $c->model('DB::Tag')
			->search($search_tags)
			->search_related('doctags')
			->search_related('item')
			#->items
		;
	}else{
		$rs = $c->model('DB::Item')->search({});
	}
	
	for ( @{ $args->{date} || [] } ) {
		if ($_->{day}) {
			push @{ $search_items->{date} ||= [] }, DateTime->new(%$_);
		}else{
			my $fr = {%$_};
			my $to = {%$_};
			$fr->{day} ||= 1;
			$fr->{month} ||=1;
			$to->{day} ||= 31;
			$to->{month} ||=12;
			push @{ $search_items->{date} ||= [] },
				{ between => [ join('-',@$fr{qw(year month day)}),join('-',@$to{qw(year month day)}) ] };
		}
	}
	use SQL::Abstract;
	my $sqa = SQL::Abstract->new();

=rem SQL

select i.*, t.* from items i
	inner join items_tags it on i.id=it.item
	inner join tags t on t.id = it.tag;

=cut

#	$c->stash->{items} = [ $rs->search($search_items) ];
	$c->stash->{items} = [ $rs->search({})->all ];
	$c->stash->{debug} = {
		args => $args,
		items => $search_items,
		tags => $search_tags,
		where_t => $sqa->where($search_tags),
		where_i => $sqa->where($search_items),
	};
    $c->stash->{template} = 'index.tt';
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
