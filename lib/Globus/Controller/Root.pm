package Globus::Controller::Root;

use strict;
use warnings;
use parent 'Catalyst::Controller';
use DateTime::Format::MySQL;

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
    $c->stash->{'pager'} = $c->create_pager(
        page_now => $c->req->parameters->{'page'} || 1,
        page_size => 10,
        events_count => $c->model('DB::Item')->search()->count(),
    );
    $c->stash->{items} = [ 
        map {
            my $item = $_;
            $item->{'str_date'} = $item->date->mdy;
            $item;
        } 
        $c->model('DB::Item')->search()->slice(
            $c->stash->{'pager'}->{'events'}->{'offset'},
            $c->stash->{'pager'}->{'events'}->{'offset'} +
              $c->stash->{'pager'}->{'page'}->{'size'}
          )
    ];
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
	
	for ( @{ $args->{author} || [] } ) {
		push @{ $search_items->{author} ||= [] }, $_;
	}
	for ( @{ $args->{date} || [] } ) {
		if (0&&$_->{day}) {
			push @{ $search_items->{date} ||= [] }, DateTime->new(%$_);
		}else{
			my $fr = {hour => 0,  minute => 0,  second => 0,  day => 1, month => 1, %$_};
			my $to = {hour => 23, minute => 59, second => 59, day => 31, month => 12, %$_};
			push @{ $search_items->{date} ||= [] },
				{ between => [ map DateTime->new(%$_),$fr,$to ] };
		}
	}
	use SQL::Abstract;
	my $sqa = SQL::Abstract->new();

	$c->stash->{items} = [ $rs->search($search_items) ];
	$c->stash->{debug} = {
		args => $args,
		items => $search_items,
		tags => $search_tags,
		where_t => $sqa->where($search_tags),
		where_i => $sqa->where($search_items),
	};
    $c->stash->{template} = 'index.tt';
}

sub about :Local :Args(0) {
    my ( $self, $c ) = @_;
    my $s=$c->{stash};
    my $schema=$c->model('DB'); #how to optain DB schema in controller
    $s->{template}='about.tt';
    $s->{authors} = [ map { +{name=>$_} } qw/
        bessarabov
        diver
        dsimonov
        dyno
        green
        hsw
        kappa
        mons
        naim
        ruz
        untone
        vany
    / ];
    $s->{stat} = [
        map { +{ name => "$_\'s", count => $c->model("DB::$_")->count } }
        qw/Item Tag ItemTag/
        ];
    #$s->{debug} = Data::Dumper::Dumper($c);
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
