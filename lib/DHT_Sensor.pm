package sensors::lib::DHT_Sensor;

use strict;
use warnings;

use sensors::lib::Database qw( get_dbh );

use Exporter qw/import/;

our @EXPORT_OK = qw(read_sensor get_current_readings get_sensors save_reading);

sub read_sensor{
    my $args = shift;

    my $GPIO = $args->{'GPIO'} || die 'Missing GPIO port';
    my $attempts = $args->{'attempts'} || 3;

    my $count = 0;
    my ( $temp, $hmid);
    while ( !$temp ){
        $count++;
        my $status = `sudo ~/Adafruit-Raspberry-Pi-Python-Code/Adafruit_DHT_Driver/Adafruit_DHT 2302 $GPIO`;
        if ( $status =~ /Temp\s=\s+(\d{2,3}\.\d)\s\*C,\sHum\s=\s*(\d{2,3}\.\d)\s%/ ){
            $temp = $1;
            $hmid = $2;
        }
        else {
            print "Couldn't find output\n";
        }
        if ($count >= $attempts){
            print "Hit attempt limit\n";
            last;
        }
    }

    return { 
        temperature => $temp,
        humidity => $hmid,
    }; 

}

#TODO: Make this method call the database and fetch the data from there

sub get_sensors{
    my $sensors = {
        'Outside' => {
            'gpio' => 17,
        },
        'Upstairs' => {
            'gpio' => 22,
        },
        'Downstairs' => {
            'gpio' => 4,
        },
    };

    return $sensors
}

sub get_current_readings{
    my $readings;
    my $dbh = get_dbh();
    my $sensors = get_sensors();

    foreach my $sensor ( keys %{$sensors}){
        my $gpio = $sensors->{$sensor}->{'gpio'}; 
    
        my $sth = $dbh->prepare('select date, temperature, humidity from readings where id = (select max(id) from readings where gpio = ?)');
    
        $sth->execute($gpio);
 
        $readings->{$sensor} = $sth->fetchrow_hashref;
    }
    return $readings;
}

1;
