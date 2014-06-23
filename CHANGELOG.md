# Epoch Changelog

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
