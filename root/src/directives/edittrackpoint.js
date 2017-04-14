goog.provide('unterwegs.EdittrackpointController');
goog.provide('unterwegs.edittrackpointDirective');

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
      'track': '=unterwegsEdittrackpointTrack',
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
 * @param {unterwegs.Track} unterwegsTrack service.
 * @param {unterwegs.Trackpoint} unterwegsTrackpoint service.
 * @constructor
 * @ngInject
 * @ngdoc controller
 * @ngname UnterwegsEdittrackpointController
 */
unterwegs.EdittrackpointController = function($scope,
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
   * @type {unterwegsx.Track}
   * @export
   */
  this.track;

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

  /**
   * @type {ol.Map}
   * @private
   */
  this.map_;

  /**
   * @type {ol.source.Vector}
   * @private
   */
  this.trackpointSource_ = new ol.source.Vector({
    features: []
  });


  this.trackpointStyle_ = new ol.style.Style({
    image: new ol.style.Circle({
      stroke: new ol.style.Stroke({
        width: 1,
        color: 'rgba(255,51,51,1)'
      }),
      radius: 4,
      snapToPixel: false
    })
  });

  /**
   * @type {ol.layer.Vector}
   * @private
   */
  this.trackpointLayer_ = new ol.layer.Vector({
    name: 'trackpoints',
    source: this.trackpointSource_,
    style: this.trackpointStyle_,
    updateWhileAnimating: true,
    updateWhileInteracting: true
  });

  // wait until constructor has done its initialization
  this.$onInit = function() {
    var map = null;
    var mapFn = this['getMapFn'];
    if (mapFn) {
      map = mapFn();
      goog.asserts.assertInstanceof(map, ol.Map);
    }
    this.map_ = map;
    map.addLayer(this.trackpointLayer_); 
  };


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
  if (this.track && this.active) {
    var ogc_fid = this.track.ogc_fid;
    var geojsonFormat = new ol.format.GeoJSON();
    this.unterwegsTrack_.getTrackPoints(ogc_fid).
    then(function(geoJSON) {
      var features = /** @type {Array.<ol.Feature>} */
          (geojsonFormat.readFeatures(geoJSON));
      this.trackpointSource_.clear(true);
      this.trackpointSource_.addFeatures(features);
    }.bind(this));
  } else {
    this.trackpointSource_.clear();
  }
};


/**
 * @private
 */
unterwegs.EdittrackpointController.prototype.updateEventsListening_ = function() {
  if (this.active && this.track && this.map_ !== null) {
    this.clickKey_ = ol.events.listen(
      this.map_, ol.events.EventType.CLICK, this.handleMapClick_, this);
  } else {
    ol.Observable.unByKey(this.clickKey_);
  }
};


/**
 * @param {Event|ol.events.Event} evt Event
 * @private
 */
unterwegs.EdittrackpointController.prototype.handleMapClick_ = function(evt) {
  this.map_.forEachFeatureAtPixel(evt.pixel, function(feature) {
    this.modalEditTrackPointShown = true;
    this.trackpoint = feature;
    this.modalEditTrackPointShown = true;
    this.$scope_.$apply();
  }.bind(this), {
    layerFilter: function(layer) {
      return layer.get('name') === 'trackpoints';
    }
  });
};


/**
 * @export
 */
unterwegs.EdittrackpointController.prototype.deleteTrackpoint = function() {

//  this.unterwegsTrackpoint_.delete(this.trackpoint.get('ogc_fid')).then(function(){
//    this['finish']();
//  }.bind(this));
  this.modalEditTrackPointShown = false;
};


unterwegs.module.controller(
  'UnterwegsEdittrackpointController', unterwegs.EdittrackpointController);
