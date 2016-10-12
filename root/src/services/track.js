goog.provide('unterwegs.Track');

goog.require('unterwegs');
goog.require('goog.uri.utils');

/**
 * The Track service uses the
 * unterwegs backend to get and update tracks
 * @constructor
 * @param {angular.$http} $http Angular http service.
 * @param {string} unterwegsServerURL URL to the unterwegs server
 * @ngInject
 * @ngdoc service
 * @ngname unterwegsTrack
 */
unterwegs.Track = function($http, unterwegsServerURL) {

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
 * @param {number} page Page of hit list
 * @return {angular.$q.Promise} Promise.
 * @export
*/
unterwegs.Track.prototype.getList = function(page) {

    var url = goog.uri.utils.appendPath(
      this.baseURL_, '/track/list'
    );
    if (page) { url += '?page=' + page; };

    return this.http_.get(url).then(
        this.handleGetData_.bind(this)
    );
};

/**
 * @param {number} ogc_fid Feature identifier
 * @return {angular.$q.Promise} Promise.
 * @export
*/
unterwegs.Track.prototype.getTrack = function(ogc_fid) {

  var url = goog.uri.utils.appendPath(
    this.baseURL_, '/track/' + ogc_fid
  ); 

  return this.http_.get(url).then(
    this.handleGetData_.bind(this)
  );
}

/**
 * @param {number} ogc_fid Feature identifier
 * @return {angular.$q.Promise} Promise.
 * @export
*/
unterwegs.Track.prototype.getTrackPoints = function(ogc_fid) {

  var url = goog.uri.utils.appendPath(
    this.baseURL_, '/track/' + ogc_fid + '/trackpoints'
  );
  return this.http_.get(url).then(
    this.handleGetData_.bind(this)
  );
}

/**
 * @param {angular.$http.Response} resp Ajax response.
 * @return {Object.<string, number>} The  object.
 * @private
 */
unterwegs.Track.prototype.handleGetData_ = function(resp) {
    return resp.data;
};

/**
 * @param {Object} track track to update.
 * @return {angular.$q.Promise} Promise.
 * @export
*/
unterwegs.Track.prototype.update = function(track) {

  var url = goog.uri.utils.appendPath( 
    this.baseURL_, '/track/' + track.ogc_fid + '/update'
  );

  return this.http_.post(url, track, {
    headers: {'Content-Type': 'application/json' }
    // withCredentials: true
  });
};

unterwegs.module.service('unterwegsTrack', unterwegs.Track);
