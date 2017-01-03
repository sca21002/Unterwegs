goog.provide('unterwegs.laptimeDirective');
goog.provide('unterwegs.LaptimeController');

goog.require('unterwegs');

goog.require('unterwegs.Calculation');
goog.require('unterwegs.Laptime');

unterwegs.laptimeDirective = function() {
  return {
    bindToController: {
      'active':   '=unterwegsLaptimeActive',
      'track':    '=unterwegsLaptimeTrack'
    },
    controller: 'UnterwegsLaptimeController',
    controllerAs: 'lpCtrl',
    templateUrl: unterwegs.baseTemplateUrl + '/laptime.html',
    // replace: true,  TODO: check this option
    restrict: 'E',
    scope: {}
  };
};

unterwegs.module.directive(
  'unterwegsLaptime', unterwegs.laptimeDirective);

/**
 * @param {angular.Scope} $scope Angular scope.
 * @param {unterwegs.Calculation} unterwegsCalculation service
 * @param {unterwegs.Laptime} unterwegsLaptime service
 * @constructor
 * @export
 * @ngInject
 * @ngdoc Controller
 * @ngname UnterwegsLaptimeController
 */
unterwegs.LaptimeController = function($scope, unterwegsCalculation, 
    unterwegsLaptime) {

  this.unterwegsLaptime = unterwegsLaptime;

  /**
   * @type {angular.Scope}
   * @private
   */
  this.$scope_ = $scope;

  /**
   * Calculation service
   * @type {unterwegs.Calculation}
   * @export
   */
  this.unterwegsCalculation = unterwegsCalculation;

  /**
   * @type {boolean}
   * @export
   */
  this.active;

  /**
   * @type {unterwegsx.Track}
   * @export
   */
  this.track;


  /**
   * @type {Object}
   * @export
   */
  this.laptimes;

  // Watch the profileType value
  $scope.$watch(
    function() {
      return this.active;
    }.bind(this),
    function(newValue, oldValue) {
      if (oldValue !== newValue) {
        if (newValue) {
          this.getData_();
        }
      }
    }.bind(this));
};

/**
  @private
 */
unterwegs.LaptimeController.prototype.getData_ = function() {
  this.unterwegsLaptime.getLaptime(this.track.ogc_fid).then(function(laptimes) {

  /**
  * @type {Object}
  * @export
  */
  this.laptimes = laptimes;
  }.bind(this));
};

unterwegs.module.controller(
  'UnterwegsLaptimeController', unterwegs.LaptimeController);
