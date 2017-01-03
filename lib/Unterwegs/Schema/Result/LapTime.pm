use utf8;
package Unterwegs::Schema::Result::LapTime;

=head1 NAME

Unterwegs::Schema::Result::LapTime

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');
__PACKAGE__->table('laptime');
__PACKAGE__->result_source_instance->is_virtual(1);

__PACKAGE__->add_columns(
  "rnd",
  {
    data_type         => "integer",
    is_nullable       => 0,
  },
  "dist",
  {
    data_type         => "bigint",
    is_nullable       => 0,
  },
  "pace",
  {
    data_type         => "text",
    is_nullable       => 0,
  },
  "hr",
  {
    data_type         => "integer",
    is_nullable       => 0,
  },
);


__PACKAGE__->result_source_instance->view_definition(q[
    SELECT rnd, dist_round AS dist, pace_round AS pace, hr FROM (
        WITH last_values AS (
            (SELECT ogc_fid, time, dist, 0 AS hr_avg 
            from track_points 
            where track_id = ? ORDER BY track_seg_point_id limit 1)
            UNION 
            SELECT ogc_fid, time, dist, hr_avg 
              FROM track_points AS tp1
            INNER JOIN (
              SELECT MAX (ogc_fid) AS ogc_fid_max, AVG(hr) AS hr_avg
              FROM track_points 
              WHERE track_id = ?
              GROUP BY dist/1000
            ) AS tp2
            ON  tp1.ogc_fid = tp2.ogc_fid_max
            ORDER BY dist
        ) 
        SELECT ROW_NUMBER() OVER() -1 AS rnd,
               dist, LAG(dist) OVER() AS dist_before,
               time, LAG(time) OVER() AS time_before,
               dist - LAG(dist) OVER() AS dist_round,
               time - lag(time) OVER() AS dur_round,
               TO_CHAR(
                (time - lag(time) OVER())
                / (dist - LAG(dist) OVER()) * 1000.0,
                'MI:SS') AS pace_round,
               ROUND(hr_avg) AS hr
          FROM last_values
    ) AS rounds WHERE dist_round > 0
]);

__PACKAGE__->meta->make_immutable;
1;
