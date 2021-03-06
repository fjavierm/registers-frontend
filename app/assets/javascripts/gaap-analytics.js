// Taken from https://raw.githubusercontent.com/alphagov/gaap-analytics/master/build/gaap-analytics.js

(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
'use strict';

module.exports = function (element, category, action, label) {
  if (element.tagName === 'SUMMARY') {
    action = action + ' opened';
  }
  element.addEventListener('click', function () {
    if (element.tagName === 'SUMMARY') {
      var actionWords = action.split(' ');
      var oldState = actionWords[actionWords.length - 1];
      var newState = element.parentElement.hasAttribute('open') ? 'closed' : 'opened';
      action = action.replace(oldState, newState);
    }
    ga('send', 'event', category, action, label); // eslint-disable-line no-undef
  });
};

},{}],2:[function(require,module,exports){
'use strict';

var addListener = require('./add-listener');

module.exports = function (elements) {
  elements.forEach(function (element) {
    var eventCategory = element.dataset.clickCategory;
    var eventAction = element.dataset.clickAction;

    switch (element.tagName) {
      case 'A':
      case 'BUTTON':
      case 'INPUT':
        var label = element.tagName === 'INPUT' ? element.value : element.innerText;
        addListener(element, eventCategory, eventAction, label);
        break;
      default:
        var childClickables = Array.prototype.slice.call(element.querySelectorAll('a, button, input[type="button"], input[type="radio"], input[type="checkbox"], summary'));

        if (childClickables.length) {
          childClickables.forEach(function (element) {
            var label = void 0;
            switch (element.tagName) {
              case 'A':
              case 'BUTTON':
              case 'SUMMARY':
                label = element.innerText;
                break;
              default:
                label = element.value;
                break;
            }

            addListener(element, eventCategory, eventAction, label);
          });
        }
        break;
    }
  });
};

},{"./add-listener":1}],3:[function(require,module,exports){
'use strict';

var buildListener = require('./build-listener');

module.exports = function () {
  var elementsToTrack = Array.prototype.slice.call(document.querySelectorAll('[data-click-events]'));

  if (elementsToTrack && typeof ga === 'function') {
    buildListener(elementsToTrack);
  }
};

},{"./build-listener":2}],4:[function(require,module,exports){
// Works in combination with the following data-attributes
// data-click-events - this just sets the thing up designed to work with A, INPUT[type~="button radio checkbox"], BUTTON
// OR you can put it on a whole div/form and it will track all the aforementioned elements within it
// data-click-category="Header" - this is the category GA will put it in
// data-click-action="Navigation link clicked" - this is the action GA will use

'use strict';

var init = require('./find-trackable');

module.exports = { init: init };

},{"./find-trackable":3}],5:[function(require,module,exports){
'use strict';

var eventTracking = require('./event-tracking');

// Add to window.GAAP if in browser context
if (window) {
  window.GAAP = window.GAAP || {};
  window.GAAP.analytics = eventTracking;
}

module.exports.eventTracking = eventTracking;

},{"./event-tracking":4}]},{},[5]);
