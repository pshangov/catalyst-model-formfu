package HTML::FormFu::Library;

use strict;
use warnings;

use Moose;
use namespace::clean -except => 'meta'; 

has model => ( is => 'ro' );
has query => ( is => 'ro' );

has cache => 
( 
    is       => 'ro', 
    required => 1,
    isa      => 'HashRef',
    traits   => ['Hash'],
    handles  => { get_cached_forms => 'get' }
);

sub form
{
    my ($self, @names) = @_;

    Carp::croak("Please specify which forms you want to access") unless @names;
    
    my @forms = 
        map { $_->stash( schema => $self->model ) }
        map { $_->query($self->query) }
        map { $_->clone } 
        $self->get_cached_forms(@names);

    $_->process for @forms;

    return wantarray 
        ? @forms
        : $forms[0];
}

__PACKAGE__->meta->make_immutable; 
