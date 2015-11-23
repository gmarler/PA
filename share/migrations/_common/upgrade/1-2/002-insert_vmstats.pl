use strict;
use warnings;

use DBIx::Class::Migration::RunScript;
use DateTime;
use DateTime::Format::Pg;

migrate {

  shift->schema->resultset('Vmstat')
    ->populate([ 
        [ 'host_fk', 'timestamp', 'freemem' ],
        [         3,  DateTime::Format::Pg->format_datetime(DateTime->from_epoch( epoch => 1447972450 )), 215003536 ],
        [         3,  DateTime::Format::Pg->format_datetime(DateTime->from_epoch( epoch => 1447972451 )), 215001480 ],
        [         3,  DateTime::Format::Pg->format_datetime(DateTime->from_epoch( epoch => 1447972452 )), 215000016 ],
        [         3,  DateTime::Format::Pg->format_datetime(DateTime->from_epoch( epoch => 1447972453 )), 215001096 ],
        [         3,  DateTime::Format::Pg->format_datetime(DateTime->from_epoch( epoch => 1447972454 )), 214998192 ],
      ]);

};


