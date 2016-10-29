var urlElements = window.location.pathname.split('/');

var unterwegsUrlElements = urlElements.slice(0, urlElements.length - 3);
unterwegsUrlElements.push('src', 'directives', 'partials');

/**
 * The default gmf template based URL, used as it by the template cache.
 * @type {string}
 */
unterwegs.baseTemplateUrl = window.location.origin + '/' + unterwegsUrlElements.join('/');
