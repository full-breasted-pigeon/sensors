package sensors::lib::Database;

use strict;
use warnings;

use DBI;

use Exporter qw/import/;

our @EXPORT_OK = qw( get_dbh );

sub get_dbh {
    my $dbh;

    eval{
        # connect
        $dbh = DBI->connect("DBI:Pg:dbname=sensors;host=localhost", "pi", "password", {'RaiseError' => 1}); #TODO: put your own connection details in here
        1;
    }
    or do{
        die "Error connecting to database $@";
    };

    return $dbh;

}

1;
