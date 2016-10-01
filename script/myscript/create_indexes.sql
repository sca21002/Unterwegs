--
-- Name: tours_pkey; Type: CONSTRAINT; Schema: public; Owner: unterwegs; Tablespace: 
--

ALTER TABLE ONLY tours
    ADD CONSTRAINT tours_pkey PRIMARY KEY (tour_id);


--
-- Name: track_points_pkey; Type: CONSTRAINT; Schema: public; Owner: unterwegs; Tablespace: 
--

ALTER TABLE ONLY track_points
    ADD CONSTRAINT track_points_pkey PRIMARY KEY (ogc_fid);


--
-- Name: tracks_pkey; Type: CONSTRAINT; Schema: public; Owner: unterwegs; Tablespace: 
--

ALTER TABLE ONLY tracks
    ADD CONSTRAINT tracks_pkey PRIMARY KEY (ogc_fid);


--
-- Name: track_points_geom_idx; Type: INDEX; Schema: public; Owner: unterwegs; Tablespace: 
--

CREATE INDEX track_points_geom_idx ON track_points USING gist (wkb_geometry);


--
-- Name: tracks_geom_idx; Type: INDEX; Schema: public; Owner: unterwegs; Tablespace: 
--

CREATE INDEX tracks_geom_idx ON tracks USING gist (wkb_geometry);


--
-- Name: track_points_track_fid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: unterwegs
--

ALTER TABLE ONLY track_points
    ADD CONSTRAINT track_points_track_fid_fkey FOREIGN KEY (track_fid) REFERENCES tracks(ogc_fid);


--
-- Name: tracks_tour_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: unterwegs
--

ALTER TABLE ONLY tracks
    ADD CONSTRAINT tracks_tour_id_fkey FOREIGN KEY (tour_id) REFERENCES tours(tour_id);

