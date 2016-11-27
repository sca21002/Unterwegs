goog.provide('unterwegs.listDirective');
goog.provide('unterwegs.ListController');

goog.require('unterwegs');
goog.require('unterwegs.Calculation');


unterwegs.listDirective = function() {
  return {
    bindToController: {
      'tracks':      '=unterwegsListTracks',    
      'page':        '=unterwegsListPage',
      'totalTracks': '=unterwegsListTotaltracks',
      'numPages':    '=unterwegsListNumpages',
      'pageChngd': '&unterwegsListPagechanged',   
      'hoverFn':     '&unterwegsListHover',    
      'clickFn':     '&unterwegsListClick'
    },
    controller: 'UnterwegsListController',
    controllerAs: 'ltCtrl',
    templateUrl: unterwegs.baseTemplateUrl + '/list.html',
    restrict: 'E',
    scope: {}
  };  
};

unterwegs.module.directive(
  'unterwegsList', unterwegs.listDirective);


/**
 * @param {angular.Scope} $scope Angular scope.
 * @param {unterwegs.Calculation} unterwegsCalculation service
 * @constructor
 * @export
 * @ngInject
 * @ngdoc Controller
 * @ngname UnterwegsListController
 */
unterwegs.ListController = function($scope, unterwegsCalculation) {

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
    *  @type {Array.<Object>}
    *  @export
   */
  this.tracks;    

  /**
   * @type {number}
   * @export
   */
  this.page;

 /**
  * @type {number}
  * @export
  */
  this.totalTracks;

  /**
   * @type {number}
   * @export
   */
  this.numPages;

  /**
   * @export
   */
  this.pageChngd;

  /**
   * @return {function(number)} A function 
   * @export
   */
  this.hoverFn;

  /**
   * @export
   */
  this.hover = this.hoverFn();

  /**
   * @return {function(Object)} A function 
   * @export
   */
  this.clickFn;

  /**
   * @export
   */
  this.click = this.clickFn();

};

/**
 * @export
 */ 
unterwegs.ListController.prototype.pageChanged = function() {
    this.pageChngd();
};

unterwegs.module.controller(
  'UnterwegsListController', unterwegs.ListController);
