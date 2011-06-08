package FormFu::Controller::BookController;

use parent qw(Catalyst::Controller::HTML::FormFu);

sub create :Local :FormConfig('book') { return }

1;
