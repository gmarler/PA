#
# Other things we might put in here:
# - ENV vars for DBIx::Class::Migration
# - Which port for Plack server to start on
#
{
  name => 'PA::Web',
  # NOTE: We have to strip PA::Web off the beginning of each module we're
  # configuring, if it is present
  'PA::Web::Model::DB' => {
    connect_info =>
      ['DBI:Pg:dbname=template1;host=localhost;port=15432','postgres',''],
  },
}
