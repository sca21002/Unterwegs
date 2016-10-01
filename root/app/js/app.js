goog.provide('app.MainController');

goog.require('unterwegs');

goog.require('ol');

/**
 * This goog.require is needed because it provides 'ngeo-map' used in
 * the template.
 * @suppress {extraRequire}
 */
goog.require('ngeo.mapDirective');
/** @suppress {extraRequire} */
goog.require('ol.Map');
goog.require('ol.View');
goog.require('ol.layer.Tile');
goog.require('ol.layer.Vector');
goog.require('ol.source.Vector');
goog.require('ol.source.XYZ');
goog.require('ol.style.Style');
goog.require('ol.style.Fill');
goog.require('ol.style.Stroke');
goog.require('ol.format.GeoJSON');
goog.require('unterwegs.Tracks');

/** @type {!angular.Module} **/
app.module = angular.module('unterwegsApp', [unterwegs.module.name]);

app.module.constant('unterwegsServerURL', 
        'http://localhost:8888/');

app.module.constant('mapboxURL', 'https://api.mapbox.com/styles/v1/' +
  'mapbox/outdoors-v9/tiles/{z}/{x}/{y}?access_token=' +      
  'pk.eyJ1Ijoic2NhMjEwMDIiLCJhIjoieWRaV0NrcyJ9.g6_31qK3mtTz_6gRrbuUGA');


/**
 * @param {unterwegs.Tracks} unterwegsTracks service
 * @constructor
 * @ngInject
 */

app.MainController = function(mapboxURL, unterwegsTracks) {

  this.unterwegsTracks = unterwegsTracks;

  this.center = [10.581, 49.682];
  this.zoom = 8;
  this.fetchedPage = 0;

  this.trackSource = new ol.source.Vector({
      features: []
  });

  /**
   * @type {ol.Map}
   * @export
   */
  this.map = new ol.Map({
    layers: [
      new ol.layer.Tile({
        source: new ol.source.XYZ({
          tileSize: [512, 512],
          url: mapboxURL
        })
      }),
      new ol.layer.Vector({
        source: this.trackSource,
        style: new ol.style.Style({
          fill: new ol.style.Fill({
            color: [255,255,255,0]
          }),
          stroke: new ol.style.Stroke({
            color: "rgba(150,28,49,0.4)",
            width: 1
          })
        })
      })
    ],  
    view: new ol.View({
      center: ol.proj.transform(
        this.center, 'EPSG:4326', 'EPSG:3857'
      ),
      zoom: this.zoom
    })
  });

  this.updateList = function() {
    unterwegsTracks.getList(this.page).then(function(data){
      /**
       *  @type {Array.<Object>}
       *  @export
      */
      this.tracks = data.tracks;
      /**
       *  @type {number}
       *  @export
      */
      this.page = data.page;
      /**
       *  @type {number}
       *  @export
      */
      this.totalTracks = data["tracks_total"];
      this.fetchedPage = this.page;
    }.bind(this));
  }; 

  this.updateList();
};


/**
 * @param {number} ogc_fid Feature identifier
 * @export
 */
app.MainController.prototype.hover = function(ogc_fid) {
    var map = /** @type {ol.Map} */ (this.map);
    var trackSource = /** @type {ol.source.Vector} */ (this.trackSource);

    this.unterwegsTracks.getTrack(ogc_fid).
    then(function(geoJSON){
      var geojsonFormat = new ol.format.GeoJSON();
      var feature = /** @type {ol.Feature} */ 
          (geojsonFormat.readFeature(geoJSON));
      trackSource.clear(true);        
      trackSource.addFeature(feature);
      var featureGeometry = /** @type {ol.geom.SimpleGeometry} */
          (feature.getGeometry());
      var mapSize = /** @type {ol.Size} */ (map.getSize());
      map.getView().fit(
        featureGeometry, mapSize,
        /** @type {olx.view.FitOptions} */ ({maxZoom: 16}));
    });
};

app.module.controller('MainController', app.MainController);
