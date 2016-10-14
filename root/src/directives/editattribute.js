goog.provide('unterwegs.EditattributeController');
goog.provide('unterwegs.editattributeDirective');

goog.require('unterwegs');
goog.require('unterwegs.Track');
goog.require('unterwegs.TravelModes');


unterwegs.editattributeDirective = function() {
  return {
    restrict: 'E',
    controller: 'UnterwegsEditattributeController',
    scope: {},
    bindToController: {  
      track:  '=',
      finish: '&'
    },    
    controllerAs: 'eaCtrl',
    templateUrl: unterwegs.baseTemplateUrl + '/editattribute.html'
  };
};

unterwegs.module.directive(
  'unterwegsEditattribute', unterwegs.editattributeDirective);

/**
 * @param {unterwegs.Track} unterwegsTrack service
 * @param {unterwegs.TravelModes} unterwegsTravelModes service
 * @constructor
 * @ngInject
 * @ngdoc controller
 * @ngname GmfEditfeatureController
 */
unterwegs.EditattributeController = function(
	unterwegsTrack, unterwegsTravelModes) {

  this.unterwegsTrack = unterwegsTrack;

  /**
   * @type {unterwegsx.Track}
   * @export
   */
  this.track;

  console.log('unterwegs.baseTemplateUrl :', unterwegs.baseTemplateUrl);

  unterwegsTravelModes.getList().then(function(travelModes){

    /**
    * @type {Object}
    * @export
    */
    this.travelModes = travelModes;
  }.bind(this));
};

/**
 * @export
 */
unterwegs.EditattributeController.prototype.updateTrack = function() {

  this.unterwegsTrack.update(this.track).then(function(){
    this['finish']();
  }.bind(this));
};

unterwegs.module.controller(
  'UnterwegsEditattributeController', unterwegs.EditattributeController);
