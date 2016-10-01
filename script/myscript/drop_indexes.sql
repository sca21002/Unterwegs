ALTER TABLE ONLY public.track_points DROP CONSTRAINT track_points_track_fid_fkey;
ALTER TABLE ONLY public.tracks DROP CONSTRAINT tracks_tour_id_fkey;

-- Table track_points

ALTER TABLE ONLY public.track_points DROP CONSTRAINT IF EXISTS track_points_pkey;
DROP INDEX public.track_points_geom_idx IF EXISTS track_points_geom_idx;

-- Table tracks

ALTER TABLE ONLY public.tracks DROP CONSTRAINT IF EXISTS tracks_pkey;
DROP INDEX public.tracks_geom_idx IF EXISTS tracks_geom_idx;

-- Table tours

ALTER TABLE tours DROP CONSTRAINT IF EXISTS tours_pkey;
