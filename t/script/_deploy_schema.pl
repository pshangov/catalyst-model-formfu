#!perl

use strict;
use warnings;

use Path::Class qw(file);
use FindBin;
use lib "$FindBin::Bin/../lib";
use Books;

my $dbfile = file( $FindBin::Bin, qw( .. root db books.db ) );

$dbfile->remove or die $! if -e $dbfile;

my $schema = Books->connect("dbi:SQLite:dbname=$dbfile", undef, undef);
$schema->deploy;

$schema->populate( 'Genre', [
	[qw( id name fiction )],
	[ 1,  "Children's",              1 ],
	[ 2,  "Fantasy",                 1 ],
	[ 3,  "Horror",                  1 ],
	[ 4,  "Mystery",                 1 ],
	[ 5,  "Romance",                 1 ],
	[ 6,  "Science Fiction",         1 ],
	[ 7,  "Short Fiction",           1 ],
	[ 8,  "Thriller/Suspense",       1 ],
	[ 9,  "Essay",                   0 ],
	[ 10, "Journal",                 0 ],
	[ 11, "History",                 0 ],
	[ 12, "Scientific Paper",        0 ],
	[ 13, "Biography",               0 ],
	[ 14, "Textbook",                0 ],
	[ 15, "Travel Book",             0 ],
	[ 16, "Technical Documentation", 0 ],
]);
