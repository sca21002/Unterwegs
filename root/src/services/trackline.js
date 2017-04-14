goog.provide('unterwegs.Trackline');

goog.require('unterwegs');
goog.require('unterwegs.Track');
goog.require('ol.format.GeoJSON');
goog.require('ol.style.Stroke');
goog.require('ol.style.Style');
goog.require('ol.geom.Point');
goog.require('ol.style.Text');
goog.require('ol.style.Fill');


/**
 * @constructor
 * @param {unterwegs.Track} unterwegsTrack service
 * @ngInject
 * @ngdoc service
 * @ngname unterwegsTrackline
*/
unterwegs.Trackline = function(unterwegsTrack) {

  /**
   * @type {ol.Map}
   * @private
   */
  this.map_;

  /**
   * Track service
   * @type {unterwegs.Track}
   * @private
   */
  this.unterwegsTrack_ = unterwegsTrack;

  /**
   * @type {ol.source.Vector}
   * @private
   */
  this.trackSource_ = new ol.source.Vector({
    features: []
  });

  this.trackStyleFunction_ = function(feature, resolution) {
    var multiLineString = /** @type{ol.geom.MultiLineString} */
      (feature.getGeometry());
    var styles = [
      new ol.style.Style({
        stroke: new ol.style.Stroke({
          color: 'rgba(255,51,51,1)',
          width: 2
        })
      })
    ];

    var lineStrings = multiLineString.getLineStrings();
    lineStrings.forEach(function(lineString) {
      var len_tot = 0;
      lineString.forEachSegment(function(start, end) {
        var dx = end[0] - start[0];
        var dy = end[1] - start[1];
        var len = Math.sqrt(dy * dy + dx * dx) / resolution;
        len_tot += len;
        if (len_tot > 100) {
          len_tot = 0;
          var rotation = Math.atan2(dy, dx);
          // arrows
          styles.push(new ol.style.Style({
            geometry: new ol.geom.Point(end),
            text: new ol.style.Text({
              text: '\uf0da',
              font: 'normal 20px FontAwesome',
              textBaseline: 'middle',
              // offsetY: -1,
              rotation: -rotation,
              fill: new ol.style.Fill({
                color: 'rgba(255,51,51,1)'
              })
            })
          }));
        }
      });
    });
    return styles;
  };

  /**
   * @type {ol.layer.Vector}
   * @private
   */
  this.trackLayer_ = new ol.layer.Vector({
    name: 'trackline',
    source: this.trackSource_,
    style: this.trackStyleFunction_,
    updateWhileAnimating: true,
    updateWhileInteracting: true
  });

};


/**
 * @param {number} ogc_fid Track Id
 * @return {angular.$q.Promise} Promise.
 * @export
 */
unterwegs.Trackline.prototype.draw = function(ogc_fid) {
  var geojsonFormat = new ol.format.GeoJSON();
  return this.unterwegsTrack_.getTrack(ogc_fid).
  then(function(geoJSON) {
    var feature = /** @type {ol.Feature} */
        (geojsonFormat.readFeature(geoJSON));
    this.trackSource_.clear();
    this.trackSource_.addFeature(feature);
    var featureGeometry = /** @type {ol.geom.SimpleGeometry} */
      (feature.getGeometry());
    if (this.map_ !== null) {
      this.map_.getView().fit(
        featureGeometry,
        /** @type {olx.view.FitOptions} */ ({maxZoom: 16}));
    }  
    return feature.getGeometry();
  }.bind(this));
};

/**
 * @param {ol.Map} map Map.
 * @export
 */
unterwegs.Trackline.prototype.init = function(map) {
  map.addLayer(this.trackLayer_);
  this.map_ = map;
};


unterwegs.module.service('unterwegsTrackline', unterwegs.Trackline);
