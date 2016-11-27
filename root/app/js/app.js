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
// goog.require('ol');
goog.require('ol.format.GeoJSON');
goog.require('ol.geom.Point');
goog.require('ol.layer.Tile');
goog.require('ol.layer.Vector');
goog.require('ol.Map');
goog.require('ol.source.Vector');
goog.require('ol.source.XYZ');
goog.require('ol.style.Fill');
goog.require('ol.style.Stroke');
goog.require('ol.style.Style');
goog.require('ol.style.Text');
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
goog.require('unterwegs.Track');
/** @suppress {extraRequire} */
goog.require('unterwegs.travelModeDirective');

/** @type {!angular.Module} **/
app.module = angular.module('unterwegsApp', [unterwegs.module.name, 'ui.bootstrap']);

app.module.constant('unterwegsServerURL', 
        'http://localhost:8888/');

app.module.constant('mapboxURL', 'https://api.mapbox.com/styles/v1/' +
  'mapbox/outdoors-v9/tiles/{z}/{x}/{y}?access_token=' +      
  'pk.eyJ1Ijoic2NhMjEwMDIiLCJhIjoieWRaV0NrcyJ9.g6_31qK3mtTz_6gRrbuUGA');


/**
 * @param {angular.Scope} $scope Angular scope.
 * @param {angular.Stimerout} $timeout Angular timeout.
 * @param {string} mapboxURL Url to Mapbox tile service.
 * @param {ngeo.FeatureOverlayMgr} ngeoFeatureOverlayMgr Feature overlay
 *     manager.
 * @param {unterwegs.Track} unterwegsTrack service
 * @constructor
 * @ngInject
 */
app.MainController = function($scope, $timeout, mapboxURL, ngeoFeatureOverlayMgr, unterwegsTrack) {

  /**
   * @type {angular.Scope}
   * @private
   */
  this.scope_ = $scope;

  this.timeout_ = $timeout;


  /**
   * Track service
   * @type {unterwegs.Track}  
   * @private
   */
  this.unterwegsTrack_ = unterwegsTrack;
            
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
  this.fetchedPage = 0;

  this.trackSource = new ol.source.Vector({
    features: []
  });

  this.view = new ol.View({
    center: ol.proj.transform(
      this.center, 'EPSG:4326', 'EPSG:3857'
    ),
    zoom: this.zoom,
    maxZoom: 20
  });

  this.trackStyleFunction = function(feature, resolution) {
    var multiLineString = /** @type{ol.geom.MultiLineString} */
 		(feature.getGeometry());  
    var styles = [
      new ol.style.Style({
        stroke: new ol.style.Stroke({
          color: "rgba(255,51,51,1)",
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
        var len = Math.sqrt(dy*dy + dx*dx) / resolution;
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
          	    color: "rgba(255,51,51,1)"
              })
            })  
          }));
        }
      });    
    });
    return styles;
  };

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
        name: 'track',  
        source: this.trackSource,
        style: this.trackStyleFunction 
      })
    ],  
    view: this.view
  });


  // Initialize the feature overlay manager with the map.
  ngeoFeatureOverlayMgr.init(this.map);


  this.updateList = function() {
    this.unterwegsTrack_.getList(this.page).then(function(data){
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
 * @return {function(number)} A function that triggers actions
 * @export
 */
app.MainController.prototype.hoverFunction = function() {
  return (    
    function(ogc_fid) {
      this.trackFidSelected = ogc_fid;
      var map = /** @type {ol.Map} */ (this.map);
      var trackSource = /** @type {ol.source.Vector} */ (this.trackSource);
      var geojsonFormat = new ol.format.GeoJSON();
      this.unterwegsTrack_.getTrack(ogc_fid).
      then(function(geoJSON){
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
        this.profileLine = /** @type {ol.geom.LineString} */ (feature.getGeometry());
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
/**
 * @export
 */
app.MainController.prototype.pageChanged = function() {
    this.timeout_(function() {
      if (this.page !== this.fetchedPage) {
        this.updateList();
      }
    }.bind(this), 0);  
};

/**
 * @export
 */
app.MainController.prototype.attributeUpdated = function() {
    this.modalEditAttributeShown = false;
    this.updateList();
};

/**
 * @export
 */
app.MainController.prototype.trackpointDeleted = function() {
//    this.updateList();
};

/**
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
