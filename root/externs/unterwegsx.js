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
 * TrackPoint
 * @typedef {{
 *     ogc_fid: (number)
 * }}
 */
unterwegsx.TrackPoint;

/**
 * The identifier for the track point
 * @type {number}
 */
unterwegsx.TrackPoint.prototype.ogc_fid;
