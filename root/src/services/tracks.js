goog.provide('unterwegs.Tracks');

goog.require('unterwegs');

/**
 * The Tracks service uses the
 * unterwegs backend to obtain tracks
 * @constructor
 * @param {angular.$http} $http Angular http service.
 * @param {string} unterwegsServerURL URL to the unterwegs server
 * @ngInject
 * @ngdoc service
 * @ngname unterwegsTracks
 */
unterwegs.Tracks = function($http, unterwegsServerURL) {

    /**
    * @type {angular.$http}
    * @private
    */
    this.$http_ = $http;

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
unterwegs.Tracks.prototype.getList = function(page) {

    var url = this.baseURL_ + '/track/list';
    if (page) { url += '?page=' + page; };

    return this.$http_.get(url).then(
        this.handleGetData_.bind(this)
    );
};

/**
 * @param {number} ogc_fid Feature identifier
 * @return {angular.$q.Promise} Promise.
 * @export
*/
unterwegs.Tracks.prototype.getTrack = function(ogc_fid) {

    var url = this.baseURL_ + '/track/' + ogc_fid; 

    return this.$http_.get(url).then(
        this.handleGetData_.bind(this)
    );
}

/**
 * @param {number} ogc_fid Feature identifier
 * @return {angular.$q.Promise} Promise.
 * @export
*/
unterwegs.Tracks.prototype.getTrackPoints = function(ogc_fid) {

    var url = this.baseURL_ + '/track/' + ogc_fid + '/trackpoints';
    return this.$http_.get(url).then(
        this.handleGetData_.bind(this)
    );
}

/**
 * @param {angular.$http.Response} resp Ajax response.
 * @return {Object.<string, number>} The  object.
 * @private
 */
unterwegs.Tracks.prototype.handleGetData_ = function(resp) {
    return resp.data;
};

unterwegs.module.service('unterwegsTracks', unterwegs.Tracks);
