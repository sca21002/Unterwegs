goog.provide('unterwegs.EdittrackpointController');
goog.provide('unterwegs.edittrackpointDirective');

goog.require('unterwegs');
goog.require('unterwegs.Trackpoint');


unterwegs.edittrackpointDirective = function() {
  return {
    restrict: 'E',
    controller: 'UnterwegsEdittrackpointController',
    scope: {},
    bindToController: {  
      trackpoint: '=',
      finish:     '&'    
    },    
    controllerAs: 'etCtrl',
    templateUrl: unterwegs.baseTemplateUrl + '/edittrackpoint.html'
  };
};

unterwegs.module.directive(
  'unterwegsEdittrackpoint', unterwegs.edittrackpointDirective);

/**
 * @param {unterwegs.Trackpoint} unterwegsTrackpoint service
 * @constructor
 * @ngInject
 * @ngdoc controller
 * @ngname UnterwegsEdittrackpointController
 */
unterwegs.EdittrackpointController = function(unterwegsTrackpoint) {


  this.unterwegsTrackpoint = unterwegsTrackpoint;

    /**
   * @type {unterwegsx.TrackPoint}
   * @export
   */
  this.trackpoint;

};

/**
 * @export
 */
unterwegs.EdittrackpointController.prototype.deleteTrackpoint = function() {

  this.unterwegsTrackpoint.delete(this.trackpoint.get('ogc_fid')).then(function(){
    this['finish']();
  }.bind(this));
};


unterwegs.module.controller(
  'UnterwegsEdittrackpointController', unterwegs.EdittrackpointController);
