goog.provide('unterwegs.Trackpoint');

goog.require('unterwegs');
goog.require('goog.uri.utils');

/**
 * The Trackpoint service uses the
 * unterwegs backend to delete a trackpoint
 * @constructor
 * @param {angular.$http} $http Angular http service.
 * @param {string} unterwegsServerURL URL to the unterwegs server
 * @ngInject
 * @ngdoc service
 * @ngname unterwegsTrackpoint
 */
unterwegs.Trackpoint = function($http, unterwegsServerURL) {

  /**
  * @type {angular.$http}
  * @private
  */
  this.http_ = $http;

  /**
  * @type {string}
  * @private
  */
  this.baseURL_ = unterwegsServerURL;
};

/**
 * @param {number} ogc_fid Feature identifier
 * @return {angular.$q.Promise} Promise.
 * @export
*/
unterwegs.Trackpoint.prototype.delete = function(ogc_fid) {

  var url = goog.uri.utils.appendPath(
    this.baseURL_, '/trackpoint/' + ogc_fid + '/delete'
  );

  return this.http_.get(url).then(
   function() {
   }
  );
};

unterwegs.module.service('unterwegsTrackpoint', unterwegs.Trackpoint);
