--- Get pace for every km of a track


SELECT distinct on (dist/1000)
  dist/1000 +1 as round, 
  last_value(dist) over wnd - first_value(dist) OVER wnd AS len,
  TO_CHAR(
    (last_value(time) over wnd - first_value(time) OVER wnd) /  
    (last_value(dist) over wnd - first_value(dist) OVER wnd) * 1000.0, 
    'MI:SS') AS pace, 
  ROUND(avg(hr) over wnd) AS hr
  FROM track_points 
  where track_id = 491 
  WINDOW wnd AS (
    PARTITION BY dist / 1000 
    order by track_seg_point_id 
    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
  );  


SELECT rnd, dist_round AS dist, pace_round AS pace, hr FROM (
    WITH last_values AS (
	(SELECT ogc_fid, time, dist, 0 AS hr_avg 
	FROM track_points 
	WHERE track_id = 449 ORDER BY track_seg_point_id limit 1)  
	UNION 
	SELECT ogc_fid, time, dist, hr_avg 
	  FROM track_points AS tp1
	INNER JOIN (
	  SELECT MAX (ogc_fid) AS ogc_fid_max, AVG(hr) AS hr_avg
	  FROM track_points 
	  WHERE track_id = 449
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
	    'MI:SS:MS') AS pace_round,
	   ROUND(hr_avg) AS hr
      FROM last_values
) AS rounds WHERE dist_round > 0;

SELECT 'total' AS total, 
  max(dist) AS dist, 
  TO_CHAR((max(time) - min(time)) / max(dist) * 1000, 'MI:SS') AS pace, 
  ROUND(avg(hr)) AS hr 
  FROM track_points 
  where track_id = 449;
