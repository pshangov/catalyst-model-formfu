package Catalyst::Model::FormFu;

# ABSTRACT: Speedier interface to HTML::FormFu for Catalyst

use strict;
use warnings;
use HTML::FormFu;
use HTML::FormFu::Library;
use Moose;
use namespace::clean -except => 'meta'; 

extends 'Catalyst::Model'; 
with 'Catalyst::Component::InstancePerContext';

has model       => ( is => 'ro', required => 1, isa => 'Str' ); 
has constructor => ( is => 'ro', required => 1, isa => 'HashRef' ); 
has forms       => ( is => 'ro', required => 1, isa => 'ArrayRef' ); 
has cache       => ( is => 'ro', required => 1, isa => 'HashRef', builder => '_build_cache' ); 

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

=pod

=head1 SYNOPSIS

	package MyApp 
	{
	
		use parent 'Catalyst';
		
		__PACKAGE__->config( 'Model::FormFu' => {
			model => 'MySchema',
			constructor => {
				config_file_path => 'myapp/root/forms',
			},
			forms => [
				{ name => 'form1', config_file => 'form1.yaml' } 
				{ name => 'form2', config_file => 'form2.yaml' } 
			]
		} );
	
	}

	package MyApp::Controller::WithForms 
	{
		use parent 'Catalyst::Controller';

		sub edit :Local 
		{
			my ($self, $c, @args) = @_;

			my $form1 = $c->model('FormFu')->form('form1');

			if ($form1->submitted_and_valid)
			...
		}

	}

	package MyApp::Model::FormFu 
	{
		use parent 'Catalyst::Model::FormFu';	
	}

=head1 DESCRIPTION

C<Catalyst::Model::FormFu> is an alternative interface for using L<HTML::FormFu> within L<Catalyst>. It differs from L<Catalyst::Controller::HTML::FormFu> in the following ways:

=for :list
* It initializes all required form objects when your app is started, and returns clones of these objects in your actions. This avoids having to call L<HTML::FormFu/load_config_file> and L<HTML::FormFu/populate> every time you display a form, potentially leading to performance improvements in persistent applications.
* It does not inherit from L<Catalyst::Controller>, and so is safe to use with other modules that do so, in particular L<Catalyst::Controller::ActionRole>.

=head1 CONFIGURATION OPTIONS

C<Catalyst::Model::FormFu> accepts the following configuration options

=over

=item forms

An arrayref of hashrefs each containing a definition of a form to load. Each hashref must have two keys: C<name>, which is the name by which your form will be accessed, and C<config_file>, which is the configuration file that will be loaded for this form.

=item constructor

A hashref of options that will be passed to C<HTML::FormFu-E<gt>new(...)> for every form that is created. 

=item model

The name of a Catalyst model class that will be place in the form stash for use by L<HTML::FormFu::Model::DBIC>.

=back

=head1 USAGE

Use the C<form> method of the model to fetch one or more forms by their names. The form is loaded with the current request parameters and processed. 

=head1 SEE ALSO

=for :list
* L<Catalyst::Controller::HTML::FormFu>
* L<HTML::FormFu::Library>

=cut
