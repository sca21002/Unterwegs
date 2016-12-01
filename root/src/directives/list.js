goog.provide('unterwegs.listDirective');
goog.provide('unterwegs.ListController');

goog.require('unterwegs');
goog.require('unterwegs.Calculation');
goog.require('unterwegs.Track');


unterwegs.listDirective = function() {
  return {
    bindToController: {
      'changed':     '=unterwegsListChanged',  
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
 * @param {unterwegs.Track} unterwegsTrack service
 * @constructor
 * @export
 * @ngInject
 * @ngdoc Controller
 * @ngname UnterwegsListController
 */
unterwegs.ListController = function($scope, unterwegsCalculation, unterwegsTrack) {

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
   * Track service
   * @type {unterwegs.Track}  
   * @private
   */
  this.unterwegsTrack_ = unterwegsTrack;


  /**
   * @type {boolean}
   * @export
   */
  this.changed;
            
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

  // Watch the changed boolean
  $scope.$watch(
    function() {
      return this.changed;
    }.bind(this),
    function(newValue) {
      if (newValue === true) {
        console.log('changed is true');    
        this.updateList_();
      }
    }.bind(this));
};


/**
 * @export
 */ 
unterwegs.ListController.prototype.pageChanged = function() {
    console.log('In pageChanged, Seite: ', this.page);
    this.updateList_();
};

/**
 * @private
 */ 
unterwegs.ListController.prototype.updateList_ = function() {
    this.unterwegsTrack_.getList(this.page).then(function(data){
      this.tracks = data.tracks;
      this.page = data.page;
      this.totalTracks = data["tracks_total"];
      this.changed = false;
    }.bind(this));
}; 


unterwegs.module.controller(
  'UnterwegsListController', unterwegs.ListController);
