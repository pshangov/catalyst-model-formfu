package Catalyst::Model::FormFu;

use strict;
use warnings;
use HTML::FormFu;
use HTML::FormFu::Library;
use Devel::Dwarn;
use Moose;
use namespace::clean -except => 'meta'; 

extends 'Catalyst::Model'; 
with 'Catalyst::Component::InstancePerContext';

has model       => ( is => 'ro', required => 1 ); 
has constructor => ( is => 'ro', required => 1 ); 
has forms       => ( is => 'ro', required => 1 ); 
has cache       => ( is => 'ro', required => 1, builder => '_build_cache' ); 

sub _build_cache
{
    my $self = shift;

    my %cache;

    foreach my $specs (@{$self->forms})
    {
        my %args = ( %{$self->constructor}, query_type => 'Catalyst' );
        my $form = HTML::FormFu->new(\%args);
        $form->load_config_file($specs->{config_file});
        $cache{$specs->{name}} = $form;
    }

    return \%cache;
}

sub build_per_context_instance { 

    my ($self, $c) = @_; 

    return HTML::FormFu::Library->new(
        cache => $self->cache,
        model => $c->model($self->model),
        query => $c->request->query_parameters,
    );
} 

__PACKAGE__->meta->make_immutable; 

