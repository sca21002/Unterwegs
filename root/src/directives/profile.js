goog.provide('unterwegs.profileDirective');
goog.provide('unterwegs.ProfileController');

goog.require('unterwegs');
/** @suppress {extraRequire} */
goog.require('ngeo.profileDirective');
goog.require('ngeo.FeatureOverlayMgr');
goog.require('ol.Feature');
goog.require('ol.style.Style');
goog.require('ol.style.Circle');
goog.require('ol.style.Stroke');
goog.require('ol.style.Fill');
goog.require('ol.geom.Point');
goog.require('ol.geom.LineString');




unterwegs.profileDirective = function() {
  return {
    bindToController: {
      profileType: '=unterwegsProfileType',
      getMapFn:    '&?unterwegsProfileMap',
      line:        '=unterwegsprofileLine',  
      trackFid:    '=unterwegsTrackFid',
      trackSource: '=unterwegsTrackSource'    
    },
    controller: 'UnterwegsProfileController',
    controllerAs: 'ctrl',
    templateUrl: unterwegs.baseTemplateUrl + '/profile.html',
    // replace: true,  TODO: check this option
    restrict: 'E',
    scope: {}
  };  
};

unterwegs.module.directive(
  'unterwegsProfile', unterwegs.profileDirective);


/**
 * @param {angular.Scope} $scope Angular scope.
 * @param {ngeo.FeatureOverlayMgr} ngeoFeatureOverlayMgr Feature overlay
 *     manager.
 * @param {unterwegs.Track} unterwegsTrack service
 * @constructor
 * @export
 * @ngInject
 * @ngdoc Controller
 * @ngname UnterwegsProfileController
 */
unterwegs.ProfileController = function($scope, ngeoFeatureOverlayMgr,
   unterwegsTrack) {

  /**
   * @type {angular.Scope}
   * @private
   */
  this.$scope_ = $scope;

  this.unterwegsTrack = unterwegsTrack;

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
   * @type {string}
   * @export
   */
  this.profileType;

  /**
   * @type {Array.<Object>}
   * @export
   */
  this.profileData = [];

  /**
   * @type {Object}
   * @private
  */
  this.keyMap_ = {
      'heartrate': 'hr',
      'elevation': 'ele',
      'speed': 'speed'
  };        

  /**
   * @type {Object<string, ngeox.profile.LineConfiguration>}
   * @private
   */
  this.linesConfiguration_ = {
    'line1': {
      style: {},
      zExtractor: function(){}
    }      
  };

  /**
   * @type {ngeox.profile.ProfileOptions}
   * @export
   */
  this.profileOptions = /** @type {ngeox.profile.ProfileOptions} */ ({
    linesConfiguration: this.linesConfiguration_,
    distanceExtractor: this.getDist_,
    hoverCallback: this.hoverCallback_.bind(this),
    outCallback: this.outCallback_.bind(this),
  });

  /**
   * @type {ol.EventsKey}
   * @private
   */
  this.pointerMoveKey_;

  /**
   * @type {ol.geom.LineString}
   * @export
   */
  this.line;

  /**
   * @type {ol.source.Vector}
   * @export
   */
  this.trackSource;


  /**
   * @type {ngeo.FeatureOverlay}
   * @private
   */
  this.pointHoverOverlay_ = ngeoFeatureOverlayMgr.getFeatureOverlay();

  /**
   * @type {ol.EventsKey}
   * @private
   */
  this.pointerMoveKey_;

  /**
   * @type {ol.Feature}
   * @private
   */
  this.snappedPoint_ = new ol.Feature();
  this.pointHoverOverlay_.addFeature(this.snappedPoint_);
   
  var hoverPointStyle = new ol.style.Style({
    image: new ol.style.Circle({
      stroke: new ol.style.Stroke({
          width: 2,
          color: '#f00'
      }),
      fill: new ol.style.Fill({
        color: "rgba(255,51,51,0.5)"
      }),
      radius: 5,
      snapToPixel: false
    })
  });

  this.pointHoverOverlay_.setStyle(hoverPointStyle);

      
  // Watch the profileType value
  $scope.$watch(
    function() {
      return this.profileType;
    }.bind(this),
    function(newValue, oldValue) {
      if (oldValue !== newValue) {
        console.log('Wert geändert: ', oldValue, ' --> ', newValue);
        this.getData_();
        this.updateEventsListening_();
      }
    }.bind(this));
};


/**
  @private
 */
unterwegs.ProfileController.prototype.getData_ = function() {
  if (this.trackFid) {
    var ogc_fid = this.trackFid;  
    this.unterwegsTrack.getTrackPoints(ogc_fid).
    then(function(geoJSON){
      var data = geoJSON.features;  
      if (this.profileType === 'elevation') {
        data = data.filter( function(element) {
          if (element['properties']['ele'] < 10) {
            return false;    
          }  else {
            return true;
          }   
        });       
      }
      this.profileData = data;
    }.bind(this));  

    this.linesConfiguration_['line1']['zExtractor'] = this.getZFactory_(this.keyMap_[this.profileType]);
  }      
};

/**
 * @private
 */
unterwegs.ProfileController.prototype.updateEventsListening_ = function() {
  if (this.profileType && this.map_ !== null) {
    this.pointerMoveKey_ = ol.events.listen(this.map_, 'pointermove',
        this.onPointerMove_.bind(this));
  } else {
    ol.Observable.unByKey(this.pointerMoveKey_);
  }
};


/**
 * @param {string} key variable of the profile
 * @return {function(Object):number} Z extractor function.
 * @private
 */
unterwegs.ProfileController.prototype.getZFactory_ = function(key) {
  /**
   * Generic Unterwegs extractor for the values in profileData.
   * @param {Object} item The item.
   * @return {number} The value.
   * @private
   */
  var getZFn = function(item) {
    if ('properties' in item && key in item['properties']) {
      return parseFloat(item['properties'][key]); 
    } 
    return 0; 
  };
  return getZFn;
};

/**
 * Extractor for the 'dist' value in profileData.
 * @param {Object} item The item.
 * @private
 */
unterwegs.ProfileController.prototype.getDist_ = function(item) {
  if ('properties' in item && 'dist' in item['properties']) {
    return item['properties']['dist'];
  }
  return 0;
};


/**
 * @param {ol.MapBrowserPointerEvent} evt An ol map browser pointer event.
 * @private
 */
unterwegs.ProfileController.prototype.onPointerMove_ = function(evt) {
  if (evt.dragging || !this.trackSource) {
    return;
  }
  var coordinate = this.map_.getEventCoordinate(evt.originalEvent);
  var multiLineString = /** @type{ol.geom.MultiLineString} */
      (this.trackSource.getFeatures()[0].getGeometry());
  var line = multiLineString.getLineString(0);
  var closestPoint = line.getClosestPoint(coordinate);
  // compute distance to line in pixels
  var eventToLine = new ol.geom.LineString([closestPoint, coordinate]);
  var pixelDist = eventToLine.getLength() / this.map_.getView().getResolution();

  if (pixelDist < 16) {
    var dist = this.getDistanceFromData_(closestPoint);
    if (dist) {
      this.profileHighlight = dist;
    }
  } else {
    this.profileHighlight = -1;
  }
  this.$scope_.$apply();
};

/**
 * @param {ol.Coordinate} point Point
 * @private
 */
unterwegs.ProfileController.prototype.getDistanceFromData_ = function(point) {
  var fakeExtent = [
    point[0] - 0.5,
    point[1] - 0.5,
    point[0] + 0.5,
    point[1] + 0.5
  ];
  var found = this.profileData.find(function(item) {
    return ol.extent.containsCoordinate(fakeExtent, item.geometry.coordinates);
  });
  return found && this.getDist_(found);
}


/**
 * @private
 */
unterwegs.ProfileController.prototype.outCallback_ = function() {
  this.point = null;
  this.snappedPoint_.setGeometry(null);
};


/**
 * @param {Object} point Point.
 * @private
 */
unterwegs.ProfileController.prototype.hoverCallback_ = function(point) {
  // An item in the list of points given to the profile.
  this.point = point;
  this.snappedPoint_.setGeometry(new ol.geom.Point(point['geometry']['coordinates']));
};

unterwegs.module.controller(
  'UnterwegsProfileController', unterwegs.ProfileController);
