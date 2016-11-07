use utf8;
package Unterwegs::Schema::Result::Track;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Unterwegs::Schema::Result::Track

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<tracks>

=cut

__PACKAGE__->table("tracks");

=head1 ACCESSORS

=head2 ogc_fid

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'tracks_ogc_fid_seq'

=head2 wkb_geometry

  data_type: 'geometry'
  is_nullable: 1
  size: '58896,16'

=head2 name

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 cmt

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 desc

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 src

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 link1_href

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 link1_text

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 link1_type

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 link2_href

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 link2_text

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 link2_type

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 number

  data_type: 'integer'
  is_nullable: 1

=head2 type

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 tour_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 file

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 start

  data_type: 'timestamp with time zone'
  is_nullable: 1

=head2 end

  data_type: 'timestamp with time zone'
  is_nullable: 1

=head2 duration

  data_type: 'interval'
  is_nullable: 1
  size: 0

=head2 len

  data_type: 'bigint'
  is_nullable: 1

=head2 avg_speed

  data_type: 'double precision'
  is_nullable: 1

=head2 travel_mode_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 start_hr

  data_type: 'timestamp with time zone'
  is_nullable: 1

=head2 duration_hr

  data_type: 'interval'
  is_nullable: 1
  size: 1

=cut

__PACKAGE__->add_columns(
  "ogc_fid",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "tracks_ogc_fid_seq",
  },
  "wkb_geometry",
  { data_type => "geometry", is_nullable => 1, size => "58896,16" },
  "name",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "cmt",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "desc",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "src",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "link1_href",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "link1_text",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "link1_type",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "link2_href",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "link2_text",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "link2_type",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "number",
  { data_type => "integer", is_nullable => 1 },
  "type",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "tour_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "file",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "start",
  { data_type => "timestamp with time zone", is_nullable => 1 },
  "end",
  { data_type => "timestamp with time zone", is_nullable => 1 },
  "duration",
  { data_type => "interval", is_nullable => 1, size => 0 },
  "len",
  { data_type => "bigint", is_nullable => 1 },
  "avg_speed",
  { data_type => "double precision", is_nullable => 1 },
  "travel_mode_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "start_hr",
  { data_type => "timestamp with time zone", is_nullable => 1 },
  "duration_hr",
  { data_type => "interval", is_nullable => 1, size => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</ogc_fid>

=back

=cut

__PACKAGE__->set_primary_key("ogc_fid");

=head1 RELATIONS

=head2 tour

Type: belongs_to

Related object: L<Unterwegs::Schema::Result::Tour>

=cut

__PACKAGE__->belongs_to(
  "tour",
  "Unterwegs::Schema::Result::Tour",
  { tour_id => "tour_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 track_points

Type: has_many

Related object: L<Unterwegs::Schema::Result::TrackPoint>

=cut

__PACKAGE__->has_many(
  "track_points",
  "Unterwegs::Schema::Result::TrackPoint",
  { "foreign.track_id" => "self.ogc_fid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 travel_mode

Type: belongs_to

Related object: L<Unterwegs::Schema::Result::TravelMode>

=cut

__PACKAGE__->belongs_to(
  "travel_mode",
  "Unterwegs::Schema::Result::TravelMode",
  { id => "travel_mode_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07045 @ 2016-10-31 22:29:51
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:E7N0DPCs6ZKR9cAo+sI/aA

use DateTime::Format::Pg;
use Geo::JSON;
use Geo::JSON::Feature;
use Data::Dumper;


sub aggregate_track_points {
    my $self = shift;
    my $func = shift;
    my $column = shift;

    my $row = $self->track_points->search(
        {},
        {
            select   => [ { $func => $column } ],
            as       => [ 'result' ],
        },
    )->single;
    my $result = $row->get_column('result');
    return $result;
}

sub start {
   my $self = shift;
        
    DateTime::Format::Pg->parse_datetime( 
        $self->aggregate_track_points('min', 'time') 
            || '00:00:00'
    ) 
}

sub end   { 
    my $self = shift; 
    DateTime::Format::Pg->parse_datetime( 
        $self->aggregate_track_points('max', 'time') 
            || '00:00:00'
    ) 
}

sub as_feature_object {
    my $self = shift;

    my $geometry_object = Geo::JSON->from_json( 
        $self->get_column('geojson_geometry')
    );  

    my %properties = map { $_ => $self->get_column($_) } 
        $self->non_geometry_columns; 

    return Geo::JSON::Feature->new({
        geometry   => $geometry_object,
        properties => \%properties,
    });
}

sub non_geometry_columns {
    my %columns = %{ shift->result_source->columns_info }; 
    grep { $columns{$_}{data_type} ne 'geometry' } keys(%columns);
}

__PACKAGE__->meta->make_immutable;
1;
