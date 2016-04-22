#
PA::Web->config(
    'PA::Web::Model::DB' => {
      connect_info =>
        ['DBI:Pg:dbname=template1;host=localhost;port=5432','postgres',''],
    },
);
