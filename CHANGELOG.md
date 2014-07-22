# Epoch Changelog

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
