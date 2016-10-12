goog.provide('unterwegs.TravelModes');

goog.require('unterwegs');

/**
 * The TravelModes service uses the
 * unterwegs backend to obtain a list of travel modes
 * @constructor
 * @param {angular.$http} $http Angular http service.
 * @param {string} unterwegsServerURL URL to the unterwegs server
 * @ngInject
 * @ngdoc service
 * @ngname unterwegsTravelModes
 */
unterwegs.TravelModes = function($http, unterwegsServerURL) {

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
 * @return {angular.$q.Promise} Promise.
 * @export
*/
unterwegs.TravelModes.prototype.getList = function() {

    var url = this.baseURL_ + '/travel_mode/list';

    return this.$http_.get(url).then(
        this.handleGetData_.bind(this)
    );
};

/**
 * @param {angular.$http.Response} resp Ajax response.
 * @return {Object.<string, number>} The  object.
 * @private
 */
unterwegs.TravelModes.prototype.handleGetData_ = function(resp) {
    return resp.data;
};

unterwegs.module.service('unterwegsTravelModes', unterwegs.TravelModes);
