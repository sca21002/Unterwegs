use utf8;
package Unterwegs::Schema::Result::Tour;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Unterwegs::Schema::Result::Tour

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

=head1 TABLE: C<tours>

=cut

__PACKAGE__->table("tours");

=head1 ACCESSORS

=head2 tour_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'tours_tour_id_seq'

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 start_date

  data_type: 'date'
  is_nullable: 1

=head2 end_date

  data_type: 'date'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "tour_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "tours_tour_id_seq",
  },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "start_date",
  { data_type => "date", is_nullable => 1 },
  "end_date",
  { data_type => "date", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</tour_id>

=back

=cut

__PACKAGE__->set_primary_key("tour_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<tours_name_key>

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->add_unique_constraint("tours_name_key", ["name"]);

=head1 RELATIONS

=head2 tracks

Type: has_many

Related object: L<Unterwegs::Schema::Result::Track>

=cut

__PACKAGE__->has_many(
  "tracks",
  "Unterwegs::Schema::Result::Track",
  { "foreign.tour_id" => "self.tour_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07045 @ 2016-10-06 11:20:31
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:rGW7vnK6TSRkk8Fcmki4xA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
