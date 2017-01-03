{
    name  => 'Unterwegs',
    stage => 'productive',

    'Model::UnterwegsDB' => {
        connect_info => {
            dsn               => 'dbi:Pg:dbname=unterwegs',
            user              => 'unterwegs',
            password          => '',
            AutoCommit        => 1,
            pg_enable_utf8    => 1,
            RaiseError        => 1,
            quote_names       => 1,
        },
    },
}
