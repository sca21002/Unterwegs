---
--- For performance reasons some columns are calculated from other columns 
---  

--- Generate track lines from track points

UPDATE tracks SET wkb_geometry = sq.geom FROM (
    SELECT track_points.track_id, ST_Multi(ST_MakeLine(track_points.wkb_geometry 
    ORDER BY track_points.ogc_fid)) AS geom 
    FROM track_points GROUP BY track_id
) AS sq 
WHERE tracks.ogc_fid = sq.track_id AND wkb_geometry is NULL;


--- Set start und end time of track 

UPDATE tracks SET start = sq.start, "end" = sq.end FROM (
    SELECT min(time) AS start, max(time) AS end, track_id FROM track_points GROUP BY track_id
) AS sq 
WHERE tracks.ogc_fid = sq.track_id AND tracks.start is NULL;


--- Set duration of track

update tracks set duration = "end" - start WHERE duration is NULL;


--- Calculate length of track from track line

UPDATE tracks SET len = ST_Length(Geography(wkb_geometry)) WHERE len is NULL;


--- Calculate average speed in km/h  

UPDATE tracks SET 
    avg_speed = Round(
            CAST(len * 3600 /(EXTRACT(EPOCH FROM duration)*1000) AS numeric) ,2)
        where EXTRACT(EPOCH FROM duration) > 0 AND avg_speed is NULL;

--- 

WITH delta_dists AS (
    SELECT ogc_fid, time, track_id, 
    COALESCE(ST_DISTANCE(Geography(wkb_geometry), Geography(LAG(wkb_geometry) 
                OVER (PARTITION BY track_id ORDER BY ogc_fid))),0) AS delta from track_points WHERE dist is NULL)
UPDATE track_points SET dist = sq.dist FROM (
    SELECT ogc_fid, ROUND(sum(delta) OVER (PARTITION BY track_id ORDER BY ogc_fid)::numeric) as dist FROM delta_dists
) as sq WHERE sq.ogc_fid = track_points.ogc_fid AND track_points.dist is NULL;   
