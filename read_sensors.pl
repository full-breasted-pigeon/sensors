package sensors;

use strict;
use warnings;

use sensors::lib::DHT_Sensor qw/ read_sensor get_sensors /;
use sensors::lib::Database qw/ get_dbh /;

use DateTime;
use DBI;

my $dt = DateTime->from_epoch( epoch => time, time_zone => 'Australia/Adelaide' );
print "Time: " . $dt->dmy . ' ' . $dt->hms . "\n";
my $date = $dt->ymd('-') . ' ' . $dt->hms(':');

my $sensors = get_sensors();


foreach my $sensor ( keys %{$sensors}){

    my $gpio = $sensors->{$sensor}->{'gpio'}; 
    my $results = read_sensor({'GPIO' => $gpio, 'attempts' => 20});
   
    print "$sensor ($gpio)\n"; 
    print "Temp: " . $results->{temperature} . "\n";
    print "Humid: " . $results->{humidity} . "\n";

    # connect
    my $dbh = get_dbh();
    
    my $sth = $dbh->prepare('INSERT INTO readings (gpio, date, temperature, humidity) VALUES (?, ?, ?, ?)');
    
    $sth->execute($gpio, $date, $results->{temperature}, $results->{humidity} );
}

1;

