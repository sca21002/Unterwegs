/**
 * Externs for Unterwegs 
 *
 * @externs
 */

/**
 * @private
 * @type {Object}
 */
var unterwegsx;

/**
 * Track
 * @typedef {{
 *     ogc_fid: (number)
 * }}
 */
unterwegsx.Track;

/**
 * The identifier for the track
 * @type {number}
 */
unterwegsx.Track.prototype.ogc_fid;

/**
 * Trackpoint
 * @typedef {{
 *     ogc_fid: (number)
 * }}
 */
unterwegsx.Trackpoint;

/**
 * The identifier for the track point
 * @type {number}
 */
unterwegsx.Trackpoint.prototype.ogc_fid;
