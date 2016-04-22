#
# Other things to put in here:
# - ENV vars for DBIx::Class::Migration
# - Which port for Plack server to start on
#
PA::Web->config(
    'PA::Web::Model::DB' => {
      connect_info =>
        ['DBI:Pg:dbname=template1;host=localhost;port=15432','postgres',''],
    },
);
