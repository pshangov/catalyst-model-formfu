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

has model_stash => ( is => 'ro', isa => 'HashRef' ); 
has constructor => ( is => 'ro', isa => 'HashRef', default => sub { {} } ); 
has forms       => ( is => 'ro', required => 1, isa => 'HashRef' ); 
has cache       => ( is => 'ro', required => 1, isa => 'HashRef', builder => '_build_cache' ); 

sub _build_cache
{
    my $self = shift;

    my %cache;

    while ( my ($id, $config_file) = each %{$self->forms} )
    {
        my %args = ( query_type => 'Catalyst', %{$self->constructor} );
        my $form = HTML::FormFu->new(\%args);
        $form->load_config_file($config_file);
        $cache{$id} = $form;
    }

    return \%cache;
}

sub build_per_context_instance { 

    my ($self, $c) = @_; 

    my %args = (
        cache => $self->cache,
        query => $c->request->query_parameters,
    );

    $args{model} = $c->model($self->model_stash->{schema}) if $self->model_stash;

    return HTML::FormFu::Library->new(%args);
} 

__PACKAGE__->meta->make_immutable; 

=pod

=head1 SYNOPSIS

	package MyApp 
	{
	
		use parent 'Catalyst';
		
		__PACKAGE__->config( 'Model::FormFu' => {
			model_stash => { schema => 'MySchema' },
			constructor => { config_file_path => 'myapp/root/forms' },
			forms => {
				form1 => 'form1.yaml',
				form2 => 'form2.yaml',
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

A hashref where keys are the names by which the forms will be accessed, and the values are the configuration files that will be loaded for the respective forms.

=item constructor

A hashref of options that will be passed to C<HTML::FormFu-E<gt>new(...)> for every form that is created. 

=item model_stash

A hashref with a C<stash> key whose value is the name of a Catalyst model class that will be place in the form stash for use by L<HTML::FormFu::Model::DBIC>.

=back

=head1 USAGE

Use the C<form> method of the model to fetch one or more forms by their names. The form is loaded with the current request parameters and processed. 

=head1 SEE ALSO

=for :list
* L<Catalyst::Controller::HTML::FormFu>
* L<HTML::FormFu::Library>

=cut
