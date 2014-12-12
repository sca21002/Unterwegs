---
--- delete from track_points, tracks, tours
---

delete from track_points;

delete from tracks;

delete from tours;

---
--- Reset index counter 
---

ALTER SEQUENCE track_points_ogc_fid_seq RESTART WITH 1;

ALTER SEQUENCE tracks_ogc_fid_seq RESTART WITH 1;

ALTER SEQUENCE tours_tour_id_seq RESTART WITH 1;
