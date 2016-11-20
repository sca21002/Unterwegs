goog.provide('unterwegs.EdittrackpointController');
goog.provide('unterwegs.edittrackpointDirective');

goog.require('ngeo.FeatureOverlayMgr');
goog.require('ol.Collection');
goog.require('ol.format.GeoJSON');
goog.require('ol.style.Circle');
goog.require('ol.style.Stroke');
goog.require('ol.style.Style');
goog.require('unterwegs');
goog.require('unterwegs.Track');
goog.require('unterwegs.Trackpoint');


unterwegs.edittrackpointDirective = function() {
  return {
    restrict: 'E',
    controller: 'UnterwegsEdittrackpointController',
    scope: {},
    bindToController: {  
      'active':   '=unterwegsEdittrackpointActive',
      'trackFid': '=unterwegsEdittrackpointTrackfid',
      'getMapFn': '&unterwegsEdittrackpointMap',
      'finish':   '&unterwegsEdittrackpointFinish'    
    },    
    controllerAs: 'etCtrl',
    templateUrl: unterwegs.baseTemplateUrl + '/edittrackpoint.html'
  };
};

unterwegs.module.directive(
  'unterwegsEdittrackpoint', unterwegs.edittrackpointDirective);

/**
 * @param {angular.Scope} $scope Angular scope.
 * @param {ngeo.FeatureOverlayMgr} ngeoFeatureOverlayMgr Feature overlay
 *   manager.
 * @param {unterwegs.Track} unterwegsTrack service.
 * @param {unterwegs.Trackpoint} unterwegsTrackpoint service.
 * @constructor
 * @ngInject
 * @ngdoc controller
 * @ngname UnterwegsEdittrackpointController
 */
unterwegs.EdittrackpointController = function($scope, ngeoFeatureOverlayMgr, 
  unterwegsTrack, unterwegsTrackpoint) {


  /**
   * Trackpoint service
   * @type {unterwegs.Trackpoint}  
   * @private
   */
  this.unterwegsTrackpoint_ = unterwegsTrackpoint;

  /**
   * Track service
   * @type {unterwegs.Track}  
   * @private
   */
  this.unterwegsTrack_ = unterwegsTrack;

  /**
   * @type {angular.Scope}
   * @private
   */
  this.$scope_ = $scope;

  /**
   * @type {number}
   * @export
   */
  this.trackFid;

  /**
   * @type {Object}
   * @export
   */
  this.trackpoint;

  /**
   * @type {boolean}
   * @export
   */
  this.modalEditTrackPointShown = false;

  /**
   * @type {boolean}
   * @export
   */
  this.active = this.active === true;

  var map = null;
  var mapFn = this['getMapFn'];
  if (mapFn) {
    map = mapFn();
    goog.asserts.assertInstanceof(map, ol.Map);
  }

  /**
   * @type {ol.Map}
   * @private
   */
  this.map_ = map;

  /**
   * @type {ngeo.FeatureOverlay}
   * @private
   */
  this.trackpointOverlay_ = ngeoFeatureOverlayMgr.getFeatureOverlay();

  var trackpointStyle = new ol.style.Style({
    image: new ol.style.Circle({
      stroke: new ol.style.Stroke({
          width: 1,
          color: 'rgba(255,51,51,1)'
      }),
      radius: 4,
      snapToPixel: false
    })
  });

  this.trackpointOverlay_.setStyle(trackpointStyle);

  // Watch the active value to activate/deactive events listening.
  $scope.$watch(
    function() {
      return this.active;
    }.bind(this),
    function(newValue, oldValue) {
      if (oldValue !== newValue) {
        this.getData_();
        this.updateEventsListening_();
      }
    }.bind(this));
};


/**
  @private
 */
unterwegs.EdittrackpointController.prototype.getData_ = function() {
  if (this.trackFid) {
    var ogc_fid = this.trackFid  
    var geojsonFormat = new ol.format.GeoJSON();
    this.unterwegsTrack_.getTrackPoints(ogc_fid).
    then(function(geoJSON){
      var featureCollection = new ol.Collection();
      this.trackpointOverlay_.setFeatures(featureCollection);
      var features = /** @type {Array.<ol.Feature>} */
          (geojsonFormat.readFeatures(geoJSON));
      features.forEach(function(item) {
        this.trackpointOverlay_.addFeature(item);      
      }.bind(this));
    }.bind(this));    
  }
};


/**
 * @private
 */
unterwegs.EdittrackpointController.prototype.updateEventsListening_ = function() {
  this.clickKey_ = ol.events.listen(
    this.map_, ol.events.EventType.CLICK, this.handleMapClick_, this);
};


/**
 * @private
 */
unterwegs.EdittrackpointController.prototype.handleMapClick_ = function(evt) {
  var hit = this.map_.forEachFeatureAtPixel(evt.pixel, function(feature) {
      this.modalEditTrackPointShown = true;
      this.trackpoint = feature;
      this.modalEditTrackPointShown = true;
      this.$scope_.$apply();
  }, this, function(layer) {
    return layer.get('name') !== 'track';
  });
};

    
/**
 * @export
 */
unterwegs.EdittrackpointController.prototype.deleteTrackpoint = function() {

//  this.unterwegsTrackpoint_.delete(this.trackpoint.get('ogc_fid')).then(function(){
//    this['finish']();
//  }.bind(this));
  console.log('Delete Point deactivated');
  this.modalEditTrackPointShown = false;
};


unterwegs.module.controller(
  'UnterwegsEdittrackpointController', unterwegs.EdittrackpointController);
