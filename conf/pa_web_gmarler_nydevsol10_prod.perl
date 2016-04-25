#
{
  name => 'PA::Web',
  # NOTE: We have to strip PA::Web off the beginning of each module we're
  # configuring, if it is present
  'Model::DB' => {
    connect_info =>
      ['DBI:Pg:dbname=template1;host=localhost;port=5432','postgres',''],
  },
}
