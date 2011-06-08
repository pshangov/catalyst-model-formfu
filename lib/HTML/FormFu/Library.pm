package HTML::FormFu::Library;

# ABSTRACT: Library of precompiled HTML::FormFu forms

use strict;
use warnings;

use Moose;
use namespace::clean -except => 'meta';
use Data::Printer;

has model => ( is => 'ro' );
has query => ( is => 'ro' );

has cache =>
(
    is       => 'ro',
    required => 1,
    isa      => 'HashRef',
    traits   => ['Hash'],
    handles  => { cached_form => 'get' }
);

sub form
{
    my ($self, @names) = @_;

    my @forms = $self->raw_form(@names);

    $_->process for @forms;

    return wantarray
        ? @forms
        : $forms[0];
}

sub raw_form
{
    my ($self, @names) = @_;

    Carp::croak("Please specify which forms you want to access") unless @names;

    my @forms =
        map { $_->stash( schema => $self->model ) }
        map { $_->query($self->query) }
        map { $_->clone }
        $self->cached_form(@names);

    return wantarray
        ? @forms
        : $forms[0];
}

__PACKAGE__->meta->make_immutable;

=pod

=head1 SYNOPSIS

    my $form1 = HTML::FormFu->new(...);
    my $form2 = HTML::FormFu->new(...);
    my $model = My::Schema->connect(...);
    my $query = { param => 'value', ... };

    my $library = HTML::FormFu::Library->new(
        cache => { form1 => $form1, form2 => $form2 },
        model => $model,
        query => $query,
    );

    if ( $library->form('form1')->submitted_and_valid ) { ... }

=head1 DESCRIPTION

C<HTML::FormFu::Library> is a module for managing L<HTML::FormFu> forms in a persistent environment, and is meant to be used in conjunction with L<Catalyst::Model::FormFu>. It is constructed with a list of populated form objects, and returns clones of these objects via the L<form> method.

=head1 METHODS

=head2 form

Given the id of one or more forms stored in the cache, clones the form objects, supplies query values, adds a model object to the form stash, processes the form and returns it.

=head2 raw_form

Same as L<form> above, but does not process the forms before returning them. Useful to avoid calling C<process> multiple times when you need to make further modification to the form object.

=head2 cached_form

Returns the original form, a clone of which you get when you use C<form> or C<raw_form>. Any changes you make to the state of a cached form will be reflected in all objects produced via subsequent calls to C<form> and C<raw_form>. Do not use unless you know what you are doing.

=head1 SEE ALSO

=for :list
* L<Catalyst::Model::FormFu>

=cut
