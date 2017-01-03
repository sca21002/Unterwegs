goog.provide('unterwegs.Laptime');

goog.require('unterwegs');
goog.require('goog.uri.utils');

/**
 * The Laptime service uses the
 * unterwegs backend to get the laptimes of a track
 * @constructor
 * @param {angular.$http} $http Angular http service.
 * @param {string} unterwegsServerURL URL to the unterwegs server
 * @ngInject
 * @ngdoc service
 * @ngname unterwegsLaptime
 */
unterwegs.Laptime = function($http, unterwegsServerURL) {

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
unterwegs.Laptime.prototype.getLaptime = function(ogc_fid) {

  var url = goog.uri.utils.appendPath(
    this.baseURL_, '/track/' + ogc_fid + '/laptime'
  );

  return this.http_.get(url).then(
    this.handleGetData_.bind(this)
  );
};

/**
 * @param {angular.$http.Response} resp Ajax response.
 * @return {Object.<string, number>} The  object.
 * @private
 */
unterwegs.Laptime.prototype.handleGetData_ = function(resp) {
  return resp.data;
};

unterwegs.module.service('unterwegsLaptime', unterwegs.Laptime);
