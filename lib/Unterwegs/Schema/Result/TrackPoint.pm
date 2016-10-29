use utf8;
package Unterwegs::Schema::Result::TrackPoint;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Unterwegs::Schema::Result::TrackPoint

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

=head1 TABLE: C<track_points>

=cut

__PACKAGE__->table("track_points");

=head1 ACCESSORS

=head2 ogc_fid

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'track_points_ogc_fid_seq'

=head2 wkb_geometry

  data_type: 'geometry'
  is_nullable: 1
  size: '58880,16'

=head2 track_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 track_seg_id

  data_type: 'integer'
  is_nullable: 1

=head2 track_seg_point_id

  data_type: 'integer'
  is_nullable: 1

=head2 ele

  data_type: 'double precision'
  is_nullable: 1

=head2 time

  data_type: 'timestamp with time zone'
  is_nullable: 1

=head2 magvar

  data_type: 'double precision'
  is_nullable: 1

=head2 geoidheight

  data_type: 'double precision'
  is_nullable: 1

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

=head2 sym

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 type

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 fix

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 sat

  data_type: 'integer'
  is_nullable: 1

=head2 hdop

  data_type: 'double precision'
  is_nullable: 1

=head2 vdop

  data_type: 'double precision'
  is_nullable: 1

=head2 pdop

  data_type: 'double precision'
  is_nullable: 1

=head2 ageofdgpsdata

  data_type: 'double precision'
  is_nullable: 1

=head2 dgpsid

  data_type: 'integer'
  is_nullable: 1

=head2 hr

  data_type: 'integer'
  is_nullable: 1

=head2 speed

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "ogc_fid",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "track_points_ogc_fid_seq",
  },
  "wkb_geometry",
  { data_type => "geometry", is_nullable => 1, size => "58880,16" },
  "track_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "track_seg_id",
  { data_type => "integer", is_nullable => 1 },
  "track_seg_point_id",
  { data_type => "integer", is_nullable => 1 },
  "ele",
  { data_type => "double precision", is_nullable => 1 },
  "time",
  { data_type => "timestamp with time zone", is_nullable => 1 },
  "magvar",
  { data_type => "double precision", is_nullable => 1 },
  "geoidheight",
  { data_type => "double precision", is_nullable => 1 },
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
  "sym",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "type",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "fix",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "sat",
  { data_type => "integer", is_nullable => 1 },
  "hdop",
  { data_type => "double precision", is_nullable => 1 },
  "vdop",
  { data_type => "double precision", is_nullable => 1 },
  "pdop",
  { data_type => "double precision", is_nullable => 1 },
  "ageofdgpsdata",
  { data_type => "double precision", is_nullable => 1 },
  "dgpsid",
  { data_type => "integer", is_nullable => 1 },
  "hr",
  { data_type => "integer", is_nullable => 1 },
  "speed",
  { data_type => "integer", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</ogc_fid>

=back

=cut

__PACKAGE__->set_primary_key("ogc_fid");

=head1 RELATIONS

=head2 track

Type: belongs_to

Related object: L<Unterwegs::Schema::Result::Track>

=cut

__PACKAGE__->belongs_to(
  "track",
  "Unterwegs::Schema::Result::Track",
  { ogc_fid => "track_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07045 @ 2016-10-29 10:16:16
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:FOQTxDZ1OlfYtbNjsE9oZw

use Geo::JSON;
use Geo::JSON::Feature;

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
