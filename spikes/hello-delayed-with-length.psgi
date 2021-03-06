my $psgi_app = sub {
  my $env = shift;
  return my $delayed_response = sub {
    my $responder = shift;
    my $writer = $responder->(
      [  200,
         [ 'Content-Type'  => 'text/plain',
           'Content-Length' => 80,
         ],
      ]);

    $writer->write('Hello');
    $writer->write(' ');
    $writer->write('World!');
    $writer->close;
  };
};
