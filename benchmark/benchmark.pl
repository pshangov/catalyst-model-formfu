use strict;
use warnings;

use rlib;
use Catalyst::Test 'FormFu';
use Benchmark qw(cmpthese timethese);

cmpthese( 100, {
    'Model::FormFu'            => 'from_model',
    'Controller::HTML::FormFu' => 'from_controller'
});

sub from_model {
    my ($res, $c) = ctx_request('/bookmodel/create?title=Test'); 
    my $form = $c->model('FormFu')->form('book');
}

sub from_controller {
    my ($res, $c) = ctx_request('/bookcontroller/create?title=Test');
    my $form = $c->stash->{'form'};
}

# |--------------------------|--------|--------------------------|---------------|
# |                          | Rate   | Controller::HTML::FormFu | Model::FormFu |
# |--------------------------|--------|--------------------------|---------------|
# | Controller::HTML::FormFu | 43.8/s |                       -- |          -55% |
# |--------------------------|--------|--------------------------|---------------|
# | Model::FormFu            | 98.4/s |                     125% |            -- |
# |--------------------------|--------|--------------------------|---------------|
