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
goog.require('ngeo.modalDirective');
/** @suppress {extraRequire} */
goog.require('ngeo.profileDirective');
/** @suppress {extraRequire} */
goog.require('unterwegs.editattributeDirective');
/** @suppress {extraRequire} */
goog.require('unterwegs.edittrackpointDirective');
/** @suppress {extraRequire} */
goog.require('unterwegs.travelModeDirective');
goog.require('ol.Map');
goog.require('ol.View');
goog.require('ol.layer.Tile');
goog.require('ol.layer.Vector');
goog.require('ol.source.Vector');
goog.require('ol.source.XYZ');
goog.require('ol.style.Style');
goog.require('ol.style.Fill');
goog.require('ol.style.Stroke');
goog.require('ol.style.Text');
goog.require('ol.format.GeoJSON');
goog.require('ol.geom.Point');
goog.require('unterwegs.Track');

/** @type {!angular.Module} **/
app.module = angular.module('unterwegsApp', [unterwegs.module.name, 'ui.bootstrap']);

app.module.constant('unterwegsServerURL', 
        'http://localhost:8888/');

app.module.constant('mapboxURL', 'https://api.mapbox.com/styles/v1/' +
  'mapbox/outdoors-v9/tiles/{z}/{x}/{y}?access_token=' +      
  'pk.eyJ1Ijoic2NhMjEwMDIiLCJhIjoieWRaV0NrcyJ9.g6_31qK3mtTz_6gRrbuUGA');


/**
 * @param {unterwegs.Track} unterwegsTrack service
 * @constructor
 * @ngInject
 */
app.MainController = function($scope, mapboxURL, unterwegsTrack) {

  /**
   * @type {angular.Scope}
   * @private
   */
  this.scope_ = $scope;

  this.unterwegsTrack = unterwegsTrack;
            
  /**
   * @type {boolean}
   * @export
   */
  this.modalEditAttributeShown = false;

  /**
   * @type {boolean}
   * @export
   */
  this.modalEditTrackPointShown = false;

  /**
   * @type {Object}
   * @export
   */
  this.track = {}; 

  /**
   * @type {Object}
   * @export
   */
  this.trackPoint = {}; 

  this.trackFidSelected;

  /**
   * @type {boolean}
   * @export
   */
  this.detailMode = false;

  /**
   * @type {boolean}
   * @export
   */
  this.loading = false;

  /**
   * @type {Object|undefined}
   * @export
   */
  this.profileData = undefined;

  var vectorLayer = new ol.layer.Vector({
    source: new ol.source.Vector(),
    style: new ol.style.Style({
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
    })
  });

  this.snappedPoint_ = new ol.Feature();
  vectorLayer.getSource().addFeature(this.snappedPoint_);

  this.center = [10.581, 49.682];
  this.zoom = 8;
  this.fetchedPage = 0;

  this.trackSource = new ol.source.Vector({
    features: []
  });

  this.trackPointSource = new ol.source.Vector({
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
        source: this.trackSource,
        style: this.trackStyleFunction 
      }),
      new ol.layer.Vector({
        name: 'trackPoints',
        source: this.trackPointSource,
        style: new ol.style.Style({
          image: new ol.style.Circle({
            stroke: new ol.style.Stroke({
                width: 1,
                color: 'rgba(255,51,51,1)'
            }),
            radius: 3,
            snapToPixel: false
          })
        })
	  }),
    ],  
    view: this.view
  });

  // Use vectorLayer.setMap(map) rather than map.addLayer(vectorLayer). This
  // makes the vector layer "unmanaged", meaning that it is always on top.
  vectorLayer.setMap(this.map);


  this.updateList = function() {
    unterwegsTrack.getList(this.page).then(function(data){
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

  ol.events.listen(this.map, ol.MapBrowserEvent.EventType.CLICK,
    function(event) {
    // this is target (this.map)
    var hit = this.map.forEachFeatureAtPixel(event.pixel, function(feature) {
      // vm.unselectPreviousFeatures();
      // feature.setStyle(vm.viewpointStyleSelectedFn(feature));
      //vm.selectedFeatures.push(feature);
      this.modalEditTrackPointShown = true;
      // modalEditTrackPointShown = true;
      this.trackPoint = feature;
      $scope.$apply();
      return true;
    }, this, function(layer) {
        return layer.get('name') === 'trackPoints';
    });
    if (!hit) { 
      //  vm.unselectPreviousFeatures(); 
    }
  },this); 

  /**
   * @type {Object}
   * @export
   */
  this.point = null;

  /**
   * @type {number|undefined}
   * @export
   */
  this.profileHighlight = undefined;

  /**
   * @type {Object}
   * @export
   */
  this.profileOptions = {
    linesConfiguration: {}
  };

  this.updateList();
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
  this.unterwegsTrack.getTrack(ogc_fid).
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
  });


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
    this.modalEditTrackPointShown = false;
    console.log("Trackpoint deleted");
    this.updateList();
};

/**
 * @param {number} ogc_fid Feature identifier
 * @export
 */
app.MainController.prototype.edit = function() {
  console.log('Bin in edit');
  var trackPointSource = /** @type {ol.source.Vector} */ (this.trackPointSource);
  if (this.detailMode === 'edit') {
    trackPointSource.clear(true); 
    this.detailMode = null;
  } else {
    this.loading = true;
    var geojsonFormat = new ol.format.GeoJSON();
    if (this.trackFidSelected) {
      var ogc_fid = this.trackFidSelected;  
      this.unterwegsTrack.getTrackPoints(ogc_fid).
      then(function(geoJSON){
        var features = /** @type {ol.Features} */ 
            (geojsonFormat.readFeatures(geoJSON));
        trackPointSource.clear(true);        
        trackPointSource.addFeatures(features);
        this.loading = false;
      }.bind(this));    
      this.detailMode === 'edit';
      this.map.on('pointermove', function(evt) {
        if (evt.dragging) {
          return;
        }
        console.log('In pointermove');
        var coordinate = this.map.getEventCoordinate(evt.originalEvent);
        this.snapToGeometry(
           coordinate, this.trackSource.getFeatures()[0].getGeometry()
        );
      }.bind(this));
    }
  }    
};

/**
 * @param {number} ogc_fid Feature identifier
 * @export
 */
app.MainController.prototype.profile = function(type) {
  console.log('Bin in profile: ', type);
  if (this.detailMode) {
    this.detailMode = null;
    this.profileData = null;
  } else {
    this.loading = true;
    if (this.trackFidSelected) {
      var ogc_fid = this.trackFidSelected;  
      this.unterwegsTrack.getTrackPoints(ogc_fid).
      then(function(geoJSON){
        var data = geoJSON.features;  
        if (type === 'elevation') {
          data = data.filter( function(element) {
            if (element['properties']['ele'] < 10) {
              return false;    
            }  else {
              return true;
            }   
          });       
        }
        this.profileData = data;
        this.loading = false;
      }.bind(this));
      this.detailMode = type;      

      /**
       * @param {Object} item
       * @return {number}
       */
      var distanceExtractor = function(item) {
            var properties = item['properties']; 
            var dist = properties['dist'];
              return dist;
      };
    

      /**
       * Factory for creating simple getter functions for extractors.
       * If the value is in a child property, the opt_childKey must be defined.
       * The type parameter is used by closure to type the returned function.
       * @param {T} type An object of the expected result type.
       * @param {string} key Key used for retrieving the value.
       * @param {string=} opt_childKey Key of a child object.
       * @template T
       * @return {function(Object): T} Getter function.
       */
      var typedFunctionsFactory = function(type, key) {
        return (
            /**
             * @param {Object} item
             * @return {T}
             * @template T
             */
            function(item) {
              return item['properties'][key];
            });
      };

      var types = {
        number: 1,
        string: ''
      };

      var profileType = 'speed';

      var keyMap = {
        heartrate: 'hr',
        elevation: 'ele',
        speed: 'speed'
      };        

      console.log('Type: ', type);
      console.log('Type: ', types.number);

      var linesConfiguration = {
        'line1': {
          style: {},
          zExtractor: typedFunctionsFactory(types.number, keyMap[type])
        }
      };
    
      /**
       * @param {Object} point Point.
       */
      var hoverCallback = function(point) {
        // An item in the list of points given to the profile.
        this.point = point;
        this.snappedPoint_.setGeometry(new ol.geom.Point(point['geometry']['coordinates']));
      }.bind(this);
    
      var outCallback = function() {
        this.point = null;
        this.snappedPoint_.setGeometry(null);
      }.bind(this);
    
      /**
       * @type {Object}
       * @export
       */
      this.profileOptions = {
        distanceExtractor: distanceExtractor,
        linesConfiguration: linesConfiguration,
    //    poiExtractor: poiExtractor,
        hoverCallback: hoverCallback,
        outCallback: outCallback
      };

    }    
  }     
}
  
  
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

/**
 * @param {ol.Coordinate} coordinate The current pointer coordinate.
 * @param {ol.geom.Geometry|undefined} geometry The geometry to snap to.
 */
app.MainController.prototype.snapToGeometry = function(coordinate, geometry) {
  var closestPoint = geometry.getClosestPoint(coordinate);
  // compute distance to line in pixels
  var dx = closestPoint[0] - coordinate[0];
  var dy = closestPoint[1] - coordinate[1];
  var dist = Math.sqrt(dx * dx + dy * dy);
  var pixelDist = dist / this.map.getView().getResolution();

  if (pixelDist < 8) {
    this.profileHighlight = closestPoint[2];
  } else {
    this.profileHighlight = -1;
  }
  this.scope_.$apply();
};

app.module.controller('MainController', app.MainController);
