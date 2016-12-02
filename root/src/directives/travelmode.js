goog.provide('unterwegs.TravelModeController');
goog.provide('unterwegs.travelModeDirective');

goog.require('unterwegs');

unterwegs.travelModeDirective = function() {
  return {
    restrict: 'E',
    controller: 'UnterwegsTravelModeController',
    scope: {},
    bindToController: {
      mode: '@'
    },
    controllerAs: 'tmCtrl',
    templateUrl: unterwegs.baseTemplateUrl + '/travelmode.html'
  };
};

unterwegs.module.directive(
  'unterwegsTravelMode', unterwegs.travelModeDirective);

/**
 * @constructor
 * @ngInject
 * @ngdoc controller
 * @ngname UnterwegsTravelModeController
 */
unterwegs.TravelModeController = function() {

  /**
   * @type {string}
   * @export
   */
  this.icon;

  /**
   * @type {string}
   * @export
   */
  this.cssClass = 'material-icons md-14';

  var mode = this.mode;
  if (mode === 'Laufen') {
    this.icon = 'directions_run';
  } else if (mode === 'Rad') {
    this.icon = 'directions_bike';
  } else if (mode === 'Gehen') {
    this.icon = 'directions_walk';
  } else if (mode === 'Auto') {
    this.icon = 'directions_car';
  } else if (mode === 'Bus') {
    this.icon = 'directions_bus';
  } else if (mode === 'Bus') {
    this.icon = 'directions_railway';
  } else if (mode === 'Tram') {
    this.icon = 'tram';
  } else if (mode === 'Schlittschuhlaufen') {
    this.cssClass = 'glyphx glyphx-skating';
  } else if (mode === 'Langlaufen') {
    this.cssClass = 'glyphx glyphx-xc-ski';
  } else {
    // console.log('Unknown mode: ', mode);
  }
};

unterwegs.module.controller(
  'UnterwegsTravelModeController', unterwegs.TravelModeController);
