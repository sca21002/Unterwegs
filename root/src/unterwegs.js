/**
 * @module unterwegs
 */
goog.provide('unterwegs');

goog.require('ngeo');


/** @type {!angular.Module} */
unterwegs.module = angular.module('unterwegs', [ngeo.module.name]);

/**
 * The default template based URL, used as it by the template cache.
 * @type {string}
 */
unterwegs.baseTemplateUrl = 'unterwegs';
