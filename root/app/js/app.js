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
 * @param {string} mapboxURL Url to Mapbox tile service.
 * @param {ngeo.FeatureOverlayMgr} ngeoFeatureOverlayMgr Feature overlay
 *     manager.
 * @param {unterwegs.Track} unterwegsTrack service
 * @constructor
 * @ngInject
 */
app.MainController = function($scope, mapboxURL, ngeoFeatureOverlayMgr, unterwegsTrack) {

  /**
   * @type {angular.Scope}
   * @private
   */
  this.scope_ = $scope;

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
   * @type {string|null}
   * @export
   */
  this.detailMode = null;

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
  console.log('This: ', this);
};


/**
 * @param {number} ogc_fid Feature identifier
 * @export
 */
app.MainController.prototype.hover = function(ogc_fid) {
  if (this.detailMode) { return null; }
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


};

/**
 * @param {Object} track track feature
 * @export
 */
app.MainController.prototype.click = function(track) {
  this.modalEditAttributeShown = true;
  this.track = track;
};


/**
/**
 * @export
 */
app.MainController.prototype.pageChanged = function() {
    if (this.page !== this.fetchedPage && !this.detailMode ) {
      this.updateList();
    }
};

/**
/**
 * @export
 */
app.MainController.prototype.attributeUpdated = function() {
    this.modalEditAttributeShown = false;
    this.updateList();
};

/**
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
 * @param {string} type Profile type
 * @export
 */
app.MainController.prototype.profile = function(type) {
  if (this.detailMode) {
    this.detailMode = null;
    this.profileData = null;
    this.profileType = null;
  } else {
    this.loading = true;
    this.profileType = type;
    this.detailMode = type;      
  }     
};
  
/**
 * @return {function(string, string)} A function that triggers actions
 * @export
 */
app.MainController.prototype.getPanelActionFunction = function() {
  return (  
    function(mode, status) {      
      console.log('panelAction: ', mode, ' - ', status);
      if (mode === 'edit') {
        console.log('Mode: edit');
        this.editTrackpointActive = status === 'on';    
      } else {
        console.log('Profile: ', mode);
        this.profileType = status === 'on' ? mode : '';
      } 
    }.bind(this));  
};

  /**
 * @param {number} speed Velocity in km per hour
 * @export
 */
app.MainController.prototype.velocity_in_min_per_km = function(speed) {
  var velocity = 60 / speed;    // [ min / km ] 
  var minutes = Math.floor(velocity);
  var seconds = Math.round(velocity * 60) % 60;
  var secs = seconds + "";
  if (secs.length < 2) {
    secs = '0' + secs;
  }
  return minutes + ':' + secs;
};


app.module.controller('MainController', app.MainController);
