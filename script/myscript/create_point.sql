INSERT INTO track_points (
    ogc_fid, 
    wkb_geometry, 
    track_id, 
    track_seg_id,
    track_seg_point_id,
    ele,
    time,
    hr,
    speed,
    fix,
    sat
) values (
    1282759,
    ST_PointFromText('POINT(12.086145 49.024197)',4326),
    449,
    0,
    0,
    0,
    '2016-10-16 14:30:35+02',
    122,
    0,
    '2d',
    4
);
