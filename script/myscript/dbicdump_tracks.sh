dbicdump -I lib -o dump_directory=./lib \
    -o use_moose=1 -o overwrite_modifications=1 -o preserve_case=1 \
    -o components='[qw(InflateColumn::DateTime)]' \
    -o debug=1 \
    -o naming='{ ALL => "v8"}' \
    Unterwegs::Schema \
    dbi:Pg:dbname=unterwegs unterwegs 
