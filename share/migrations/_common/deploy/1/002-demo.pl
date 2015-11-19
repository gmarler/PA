use strict;
use warnings;

use DBIx::Class::Migration::RunScript;

migrate {

  my $host_rs = shift->schema->resultset('Host');

  $host_rs->create(
    {
      name => 'nydevsol10',
      time_zone => 'America/New_York',
    }
  );
  $host_rs->create(
    {
      name => 'sundev51',
      time_zone => 'America/New_York',
    },
  );
  $host_rs->create(
    {
      name => 'nysolperf1',
      time_zone => 'America/New_York',
    },
  );
  $host_rs->create(
    {
      name => 'p569',
      time_zone => 'America/New_York',
    },
  );
  $host_rs->create(
    {
      name => 'p315',
      time_zone => 'Europe/London',
    },
  );
    
};
