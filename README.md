## Epoch - The Fastly Charting Library
By Ryan Sandor Richards

### Introduction

Epoch is a general purpose charting library for application developers and visualization designers. It focuses on two different aspects of
visualization programming: **static charts** for creating historical reports, and **real-time charts** designed for displaying frequently 
updating time-series data.

### Getting Started

First, download the following libraries and place them in your project's javascript directory:

1. [d3](https://github.com/mbostock/d3)
2. [jQuery](https://github.com/jquery/jquery)

Next, locate and download the `epoch.X.Y.Z.min.js` and `epoch.X.Y.Z.min.css` files in this repository, and place
them in your project (note: `X.Y.Z` is a placeholder for the current version of Epoch).

Finally, include all the required JavaScript and CSS files into your source in the usual manner:

```html
<html>
  <head>
    <!-- jQuery, d3, and other includes here ... -->
    <script src="js/epoch.min.X.Y.Z.js"></script>
    <link rel="stylesheet" href="css/epoch.X.Y.Z.min.css">
  </head>
  ...
</html>
```

### Available Charts

#### Static Charts

Epoch's **Static** charts are implemented using d3 over a thin class hieracrchy. The classes perform common tasks (such as setting up
scales, axes, etc.) while the individual charts implement their own specialized drawing routines. Epoch comes with the following
static charts out of the box:

* Area - Good old stacked area chart
* Bar - Currently supports grouped bars ("stacked", and "normal stacked" coming soon)
* Line - The granddaddy of all charts (didn't Newton come up with it or something?)
* Pie - Also supports inner radius for creating Donut charts
* Scatter - Nice for visualizing statistical data

#### Real-time Charts

Epoch's **real-time** charts have been fine tuned for displaying frequently updating *timeseries* data. To make them performant (aka
not crash the browser) we've implemented the charts using a hybrid approach of d3 SVG with custom HTML5 Canvas rendering. Here is a
list of the charts that are available:

* Area - Area chart that uses a discrete time-domain (via unix timestamps)
* Bar - Supports only "stacked" bar charts (again uses timestamps for the domain)
* Gauge - Similar to a speedometer
* Heatmap - Visualizes histogram data / time (multiple layers use color blending)
* Line - Run of the mill line chart with a discrete time domain


### Examples

#### Static Area Chart

In this example we will show you how to quickly make a static area chart using epoch. First, let's take a gander at the data format for this type of
chart:

```javascript
var areaChartData = [
  // Define the first "layer" to be shown by the chart...
  {
    label: 'Cons',
    values: [
      { x: 0, y: 10 },
      { x: 1, y: 8 },
      { x: 2, y: 6 },
      { x: 3, y: 4 }
    ]
  },

  // Let's add another layer...
  {
    label: 'Pros',
    values: [
      { x: 0, y: 2 },
      { x: 1, y: 4 },
      { x: 2, y: 8 },
      { x: 3, y: 16 } 
    ]
  }
];
```

As shown above, data is defined as an array of *layers* that are composed together to display the chart. Each layer has an optional label and
must contain a list of values to display.

Next, given we have a suitable HTML container for the chart (in this case a div with the id `areaChart`) we can simply add the chart into the
dom and render it using the jQuery `.epoch` function:

```javascript
var areaChart = $('div#areaChart').epoch({
  type: 'area',
  data: areaChartData
});
```

Note that the chart is automatically sized to fit it's parent container (`div#areaChart`) and the jQuery function returns the chart instance
(which we assign to the `areaChart` variable).

The chart can even be updated with automatic animated transitions. To see it in action simply call the `update()` method on the instance, like so:

```javascript
// Define some new data
var newAreaChartData = [ ... ];

// Update the chart
areaChart.update(newAreaChartData);
```


#### Real-time Bar Chart

First, examine this example bandwidth data and how it is formatted:

```javascript
var bandwidthData = [
  {
    label: 'Average Bandwidth',
    values: [
      { time: 1376088486, y: 1024 },
      { time: 1376088487, y: 768 },
      { time: 1376088488, y: 2038 },
      { time: 1376088489, y: 384 },
      { time: 1376088490, y: 6500 },
      { time: 1376088491, y: 900 },
      { time: 1376088492, y: 3230 },
      { time: 1376088493, y: 1738 },
      { time: 1376088494, y: 5692 },
      { time: 1376088495, y: 802 }
    ]
  }
];
```

Using this data we can easily add a chart to a page by using jQuery:

```javascript
var barChart = $('div#bar').epoch({
  type: 'time.bar',
  data: bandwidthData
});
```

The chart is automatically sized to fit the containing div (`div#bar`) and the data is rendered to the page immediately. The jQuery method
`.epoch` returns a chart instance which we assign to the variable `barChart`.

Now assume that we have an endpoint on our api that will give us the latest bandwidth information, let call it `/stats/bandwidth`. Here's
and example of how one might pull and add the information using the chart's `push()` method:

```javascript
function pollBandwidthData() {
  $.get('/stats/bandwidth', function(data) {
    barChart.push(data);
  })
}

setInterval(pollBandwidthData, 1000);
```

Upon calling the `push` method the new data will be added to the visualization and smoothly animated to appear as the next data point.


### Static Charts and Data Formats

#### Area

```html
<div id="areaChart" style="width: 800px; height: 200px"></div>
<script>
  $('#areaChart').epoch({
    type: 'area',
    data: chartData // Must follow the format as defined below...
  });
</script>
```

**Options:**

* *width* - Explicit width for the chart (overrides auto-fit to container width)
* *height* - Explicit height for the chart (overrides auto-fix to container height)
* *margins* - Explicit margin overrides for the chart. Example: `{ top: 50, right: 30, bottom: 100, left: 40 }`
* *axes* - Which axes to display. Example: `['top', 'right', 'bottom', 'left']`
* *ticks* - Number of ticks to display on each axis. Example: `{ top: 10, right: 5, bottom: 20, left: 5 }`
* *tickFormats* - What formatting function to use when displaying tick labels. Ex: `{ bottom: function(v) { return '$' + v; } }`

**Data Format:**

```javascript
// Data should be an array containing layers
[
  // The first layer
  {
    label: "Layer 1",
    values: [ {x: 0, y: 100}, {x: 20, y: 1000}, ... ]
  },

  // The second layer
  {
    label: "Layer 2",
    values: [ {x: 0, y: 78}, {x: 20, y: 98}, ... ]
  },

  // Add as many layers as you would like!
]
```



### Real-time Charts and Data Formats 



### Developing Epoch

To work on the epoch charting library itself do the following:

1. Clone the repository
2. Install the npm package `node-minify`; `npm install -g node-minify`, then `npm link node-minify`. 
2.2 `npm install -g codo` - Documentation (CLEAN ME UP)
3. Run `cake build` from the project directory
4. View `docs/static.html` and `docs/time.html` for a quick overview of the available features
5. Scour the source for more detailed information (formal documentation coming soon)
6. Let cool and enjoy (serves millions).

