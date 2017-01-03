goog.provide('unterwegs.Calculation');

goog.require('unterwegs');

/**
 * The Calculation service offers
 * conversions between physical values
 * @constructor
 * @ngInject
 * @ngdoc service
 * @ngname unterwegsCalculation
 */
unterwegs.Calculation = function() {
};

/**
 * @param {number} speed Velocity in km per hour
 * @return {string} Speed in minutes:secs per km
 * @export
 */
unterwegs.Calculation.prototype.velocityInMinPerKm = function(speed) {
  var velocity = 60 / speed;    // [ min / km ]
  var minutes = Math.floor(velocity);
  var seconds = Math.round(velocity * 60) % 60;
  var secs = seconds + '';
  if (secs.length < 2) {
    secs = '0' + secs;
  }
  var mins = minutes + '';
  if (mins.length < 2) {
    mins = '0' + mins;
  }
  return mins + ':' + secs;
};


unterwegs.module.service('unterwegsCalculation', unterwegs.Calculation);
