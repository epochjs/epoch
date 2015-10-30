# Epoch Changelog

## 0.8.4 - October 30th, 2015
### Bug Fixes
* Fixed bower css path (@ftaiolivista)

## 0.8.3 - October 17th, 2015
### Enhancements / Features
* Added `redraw` method for clearing styles on canvas based charts (#196, @woozyking)

## 0.8.2 - October 13th, 2015
### Enhancements / Features
* Charts now auto draw on construction (#195)

## 0.8.1 - October 13th, 2015
### Enhancements / Features
* Added packagist/composer package manager support (#202)

### Bug Fixes
* Real-time charts no-longer error when pushing first data point after initialized
  with empty data layers. (#203)

## 0.8.0 - October 10th, 2015
### Enhancements / Features
* Multi-axis support for basic and real-time line plots
* Added new gulp build-system (for development)

## 0.7.1 - October 4th, 2015
* Moved minified source to `dist/js` and `dist/css` respectively
* Added non-minified source to aforementioned directories

## 0.7.0 - October 4th, 2015

### Enhancements / Features
* New basic chart: Histogram
* New Feature: Data formatters
* Chart layers can now be hidden/shown

### Bug Fixes
* Ticks now working for ordinal scaled bar charts
* Fixed CSS builds by updating NPM sass-node package
* Removed versions from minified release files (@RyanNielson)
* Time based graphs can now have fixed ranges (@willwhitney)
* NPM Package: epoch-charting (@sompylasar)
* Right axes now using correct formatters (@Dav1dde)
* Add 'main' attribute enabling webpack support. (@WRidder)
* Fixed Bower D3 Dependencies (@loopj)
* Fixed CSS errors by using `transparent` instead of `none` (@mwsmith2)
* Fixed bower "version" property (@kkirsche)

## 0.6.0 - July 21st, 2014

### Enhancements / Features

* Source code restructure for easier programming
* Replaced Compass with node-sass
* Removed put.js from the repository
* Removed dependency on jQuery
* Added CSS controlled themes
  * New "Dark" theme for dark backgrounds
* Registered with bower
* Added option accessor / mutator to all charts (making them adaptive)
* Added bubble charts (special case of scatter plots)
* Added MooTools and Zepto Adapters
* Added Core Library Unit Testing
* New `domain` and `range` options for basic charts

### Bug Fixes

* Event `.off` method was completely busted, fixed
* Swapped terminology for horizontal and vertical bar plots
* Removed `isVisible` and related rendering hacks (caused all sorts of woe)


## 0.5.2 - June 24th, 2014

### Enhancements / Features

* #36 - Fixed the readme to focus on development
* #54 - Added vertical orientation option to the basic bar chart

## 0.5.1 - June 23rd, 2014

### Bug Fixes

* #52 - Replaced instances of `$` with `jQuery` (ambiguous, otherwise)

## 0.5.0 - June 23rd, 2014

### Enhancements / Features

* #32 - QueryCSS greatly enhanced - now builds a full DOM context when computing styles
* #42 - Heat map now allows for painting of "zero" values via a new `paintZeroValues` option
* #43 - Heat map color computation abstracted out of `_paintEntry` (makes it easier to extend)

### Bug Fixes

* #22 - Fixed an issue with pie chart transitions
* #30 - Layers without labels now correctly render on a various basic charts
* #31 - Real-time Line Chart thickness fixed by taking pixel ratio into account
* #41 - Fixed bucketing issues with the Heat Map
* #46 - Removed default black stroke from the Real-Time Area chart
