goog.provide('app.MainController');

goog.require('unterwegs');
goog.require('ngeo.FeatureOverlayMgr');
/**
 * This goog.require is needed because it provides 'ngeo-map' used in
 * the template.
 * @suppress {extraRequire}
 */
goog.require('ngeo.mapDirective');
/** @suppress {extraRequire} */
goog.require('ngeo.modalDirective');
goog.require('ol.layer.Tile');
goog.require('ol.Map');
goog.require('ol.source.XYZ');
goog.require('ol.View');
/** @suppress {extraRequire} */
goog.require('unterwegs.editattributeDirective');
/** @suppress {extraRequire} */
goog.require('unterwegs.edittrackpointDirective');
/** @suppress {extraRequire} */
goog.require('unterwegs.listDirective');
/** @suppress {extraRequire} */
goog.require('unterwegs.panelDirective');
/** @suppress {extraRequire} */
goog.require('unterwegs.profileDirective');
goog.require('unterwegs.Trackline');
/** @suppress {extraRequire} */
goog.require('unterwegs.travelModeDirective');

/** @type {!angular.Module} **/
app.module = angular.module('unterwegsApp', 
  [unterwegs.module.name, 'ui.bootstrap']);

app.module.constant('unterwegsServerURL', 'http://localhost:8888/');

app.module.constant('mapboxURL', 'https://api.mapbox.com/styles/v1/' +
  'mapbox/outdoors-v9/tiles/{z}/{x}/{y}?access_token=' +      
  'pk.eyJ1Ijoic2NhMjEwMDIiLCJhIjoieWRaV0NrcyJ9.g6_31qK3mtTz_6gRrbuUGA');


/**
 * @param {string} mapboxURL Url to Mapbox tile service.
 * @param {ngeo.FeatureOverlayMgr} ngeoFeatureOverlayMgr Feature overlay
 *     manager.
 * @param {unterwegs.Trackline} unterwegsTrackline service
 * @constructor
 * @ngInject
 */
app.MainController = function(mapboxURL, ngeoFeatureOverlayMgr, unterwegsTrack,
  unterwegsTrackline) {

  /**
   * Trackline service
   * @type {unterwegs.Trackline}  
   * @private
   */
  this.unterwegsTrackline_ = unterwegsTrackline;
            
  /**
   * @type {boolean}
   * @export
   */
  this.modalEditAttributeShown = false;

  /**
   * @type {boolean}
   * @export
   */
  this.editTrackpointActive = false;


  /**
   * @type {boolean}
   * @export
   */
  this.listChanged;


  /**
   * @type {Object}
   * @export
   */
  this.track = {}; 

  /**
   * @type {number}
   * @export
   */
  this.trackFidSelected;

  /**
   * @type {boolean}
   * @export
   */
  this.loading = false;


  /**
   * @type {string|null}
   * @export
   */
  this.profileType = ''; 

  /**
   * @type {ol.geom.LineString}
   * @export
   */
  this.profileLine = null;

  this.center = [10.581, 49.682];
  this.zoom = 8;

  this.view = new ol.View({
    center: ol.proj.transform(
      this.center, 'EPSG:4326', 'EPSG:3857'
    ),
    zoom: this.zoom,
    maxZoom: 20
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
    ],  
    view: this.view
  });


  // Initialize the feature overlay manager with the map.
  ngeoFeatureOverlayMgr.init(this.map);

  this.listChanged = true;
};


/**
 * @return {function(number)} A function that triggers actions
 * @export
 */
app.MainController.prototype.hoverFunction = function() {
  return (    
    function(ogc_fid) {
      this.trackFidSelected = ogc_fid;
      this.unterwegsTrackline_.draw(ogc_fid, this.map)
      .then(function(multiLineString){
        this.profileLine = multiLineString.getLineString(0);
      }.bind(this));  
    }.bind(this));  
};

/**
 * @return {function(Object)} A function that triggers actions
 * @export
 */
app.MainController.prototype.clickFunction = function() {
  return (    
    function(track) {
      this.modalEditAttributeShown = true;
      this.track = track;
    }.bind(this));  
};

/**
 * @export
 */
app.MainController.prototype.attributeUpdated = function() {
  this.modalEditAttributeShown = false;
  this.listChanged = true;
};

/**
 * @export
 */
app.MainController.prototype.trackpointDeleted = function() {
  // this.listChanged = true;
};

/**
 *
 * @export
 */
app.MainController.prototype.edit = function() {
  this.editTrackpointActive = true;
};

  
/**
 * @return {function(string, string)} A function that triggers actions
 * @export
 */
app.MainController.prototype.getPanelActionFunction = function() {
  return (  
    function(mode, status) {      
      if (mode === 'edit') {
        this.editTrackpointActive = status === 'on';    
      } else {
        this.profileType = status === 'on' ? mode : '';
      } 
    }.bind(this));  
};

app.module.controller('MainController', app.MainController);
