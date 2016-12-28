goog.provide('unterwegs.Trackline');

goog.require('ngeo.FeatureOverlayMgr');
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
 * @param {ngeo.FeatureOverlayMgr} ngeoFeatureOverlayMgr Feature overlay
 * @param {unterwegs.Track} unterwegsTrack service
 * @ngInject
 * @ngdoc service
 * @ngname unterwegsTrackline
*/
unterwegs.Trackline = function(ngeoFeatureOverlayMgr, unterwegsTrack) {

    /**
   * @type {ngeo.FeatureOverlay}
   * @private
   */
  this.trackOverlay_ = ngeoFeatureOverlayMgr.getFeatureOverlay();

  /**
   * Track service
   * @type {unterwegs.Track}
   * @private
   */
  this.unterwegsTrack_ = unterwegsTrack;

  var trackStyleFunction = function(feature, resolution) {
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

  this.trackOverlay_.setStyle(trackStyleFunction);

};


/**
 * @param {number} ogc_fid Track Id
 * @param {ol.Map} map Map
 * @return {angular.$q.Promise} Promise.
 * @export
 */
unterwegs.Trackline.prototype.draw = function(ogc_fid, map) {
  var geojsonFormat = new ol.format.GeoJSON();
  return this.unterwegsTrack_.getTrack(ogc_fid).
  then(function(geoJSON) {
    var feature = /** @type {ol.Feature} */
        (geojsonFormat.readFeature(geoJSON));
    this.trackOverlay_.clear();
    this.trackOverlay_.addFeature(feature);
    var featureGeometry = /** @type {ol.geom.SimpleGeometry} */
      (feature.getGeometry());
    var mapSize = /** @type {ol.Size} */ (map.getSize());
    map.getView().fit(
      featureGeometry, mapSize,
      /** @type {olx.view.FitOptions} */ ({maxZoom: 16}));
    return feature.getGeometry();
  }.bind(this));
};

unterwegs.module.service('unterwegsTrackline', unterwegs.Trackline);
