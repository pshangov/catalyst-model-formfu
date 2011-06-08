package FormFu;

use strict;
use warnings;

use Catalyst::Runtime 5.80;
use FindBin     qw();
use Path::Class qw(file dir);
use parent      qw(Catalyst);
use Catalyst    qw(Static::Simple);

our $VERSION = '0.01';

__PACKAGE__->config( 

	name => 'FormFu',

	'View::TT' => {
		TEMPLATE_EXTENSION => '.tt',
		INCLUDE_PATH => dir( $FindBin::Bin, qw( .. root tmpl ) ),
		CATALYST_VAR => 'c',	
	},
    
    'Model::FormFu' => {
        constructor => {
            config_file_path => dir( $FindBin::Bin, qw( root forms ) )->stringify,
        },
        forms => {
            book => 'book.conf',
        }
    },

    'Controller::HTML::FormFu' => {
		constructor => {
			config_file_path => dir( $FindBin::Bin, qw( root forms ) )->stringify,
		},
	},
);

__PACKAGE__->setup();

1;
