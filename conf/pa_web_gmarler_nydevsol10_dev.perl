PA::Web->config(
    'PA::Web::Model::DB' => {
      connect_info =>
        ['DBI:Pg:dbname=template1;host=localhost;port=15432','postgres',''],
    },
);
