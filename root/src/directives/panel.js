goog.provide('unterwegs.panelDirective');
goog.provide('unterwegs.PanelController');

goog.require('unterwegs');


unterwegs.panelDirective = function() {
  return {
    bindToController: {
      'panelActionFn': '&unterwegsPanelAction'    
    },
    controller: 'UnterwegsPanelController',
    controllerAs: 'plCtrl',
    templateUrl: unterwegs.baseTemplateUrl + '/panel.html',
    restrict: 'E',
    scope: {}
  };  
};

unterwegs.module.directive(
  'unterwegsPanel', unterwegs.panelDirective);


/**
 * @constructor
 * @export
 * @ngInject
 * @ngdoc Controller
 * @ngname UnterwegsPanelController
 */
unterwegs.PanelController = function() {

    /**
     * @type {string}
     * export
     */
    this.active = '';

    /**
     * @return {function(string, string)} A function that triggers actions
     * @export
     */
    this.panelActionFn;

    /**
     * @export
     */ 
    this.panelAction = this.panelActionFn();
};

/**
 * @param {string} mode Action mode
 * @export
 */
unterwegs.PanelController.prototype.action = function(mode) {
  if (this.active === mode) {
    this.active = '';    
    this.panelAction(mode, 'off');
  } else {
    if (this.active) {
      this.panelAction(this.active, 'off');    
    }  
    this.active = mode;  
    this.panelAction(mode, 'on');
  }  
}



unterwegs.module.controller(
  'UnterwegsPanelController', unterwegs.PanelController);
