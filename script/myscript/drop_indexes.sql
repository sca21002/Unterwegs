ALTER TABLE track_points DROP CONSTRAINT IF EXISTS "track_points_track_fid_fkey";
ALTER TABLE tracks DROP CONSTRAINT IF EXISTS "tracks_tour_id_fkey";

-- Table track_points

ALTER TABLE track_points DROP CONSTRAINT IF EXISTS "track_points_pkey";
DROP INDEX IF EXISTS "track_points_pkey";
DROP INDEX IF EXISTS "track_points_geom_idx";

-- Table tracks

ALTER TABLE tracks DROP CONSTRAINT IF EXISTS "tracks_pkey";
DROP INDEX IF EXISTS "tracks_pkey";
DROP INDEX IF EXISTS "tracks_geom_idx";

-- Table tours

ALTER TABLE tours DROP CONSTRAINT IF EXISTS "tours_pkey";
DROP INDEX IF EXISTS "tours_pkey";
