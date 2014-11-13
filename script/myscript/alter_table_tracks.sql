ALTER TABLE tracks
    ADD COLUMN tour_id INTEGER REFERENCES tours (tour_id);
