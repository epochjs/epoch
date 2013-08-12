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

### Quick Start Examples

#### Static Area Chart

Let's make a quick static area chart using epoch. First, let's take a gander at the data format for this type of chart:

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


### Static Charts

Epoch's **Static** charts are implemented using d3 over a thin class hieracrchy. The classes perform common tasks (such as setting up
scales, axes, etc.) while the individual charts implement their own specialized drawing routines. This section details each of the available
charts in detail.

#### Area

The static area chart is used to plot multiple data series atop one another. The chart expects data as an array of layers
each with their own indepenent series of values. To begin, let's take a look at some example data:

```javascript
var areaChartData = [
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
];
```
As you can see the data is arranged as an array of layers. Each layer is an object that has the following properties:

* `label` - The name of the layer
* `values` - An array of values (each value having an `x` and `y` coordinate)

For the best results each layer should contain the same number of values, with the same `x` coordinates. This will allow
d3 to make the best looking graphs possible.

Given that you have data in the appropriate format, instantiating a new chart is fairly easy. Simply create a container
element in HTML and use the jQuery bindings to create, place, and draw the chart:

```html
<div id="areaChart" style="width: 800px; height: 200px"></div>
<script>
  $('#areaChart').epoch({
    type: 'area',
    data: chartData // Must follow the format as defined below...
  });
</script>
```

Note how we explicitly set the `width` and `height` for the container div (`div#areaChart`)? This allows Epoch to automatically
size the chart to fill the container (using computed width and height values).

In the script you'll see that we are passing an **options array** to the `.epoch` jQuery function. The ones we defined there
tell Epoch what `type` of chart you wish to make and what `data` it should use. Here's a complete list of options that will
work with the `area` type chart:

* *width* - Explicit width for the chart (overrides auto-fit to container width)
* *height* - Explicit height for the chart (overrides auto-fix to container height)
* *margins* - Explicit margin overrides for the chart. Example: `{ top: 50, right: 30, bottom: 100, left: 40 }`
* *axes* - Which axes to display. Example: `['top', 'right', 'bottom', 'left']`
* *ticks* - Number of ticks to display on each axis. Example: `{ top: 10, right: 5, bottom: 20, left: 5 }`
* *tickFormats* - What formatting function to use when displaying tick labels. Ex: `{ bottom: function(v) { return '$' + v; } }`


#### Bar

```html
<div id="barChart" style="width: 300px; height: 100px"></div>
<script>
  $('#barChart').epoch({
    type: 'bar',
    data: chartData // Must follow the format as defined below...
  });
</script>
```

The Bar chart has the following **Options**:

* *width* - Explicit width for the chart (overrides auto-fit to container width)
* *height* - Explicit height for the chart (overrides auto-fix to container height)
* *margins* - Explicit margin overrides for the chart. Example: `{ top: 50, right: 30, bottom: 100, left: 40 }`
* *axes* - Which axes to display. Example: `['top', 'right', 'bottom', 'left']`
* *ticks* - Number of ticks to display on each axis. Example: `{ top: 10, right: 5, bottom: 20, left: 5 }`
* *tickFormats* - What formatting function to use when displaying tick labels. Ex: `{ bottom: function(v) { return '$' + v; } }`

And uses the following **Data Format**:

```javascript
// Data is an array containing independent groups
[
  // First bar group
  {
    label: 'Group 1',
    values: [
      { x: 'A', y: 30 },
      { x: 'B', y: 10 },
      { x: 'C', y: 12 },
      ...
    ]
  }

  // Second group
  {
    label: 'Group 2',
    values: [
      { x: 'A', y: 20 },
      { x: 'B', y: 39 },
      { x: 'C', y: 8 },
      ...
    ]
  },

  // Add more groups if you'd like!
]
```

#### Line

```html
<div id="lineChart" style="width: 800px; height: 200px"></div>
<script>
  $('#areaChart').epoch({
    type: 'line',
    data: chartData // Must follow the format as defined below...
  });
</script>
```

The Line chart has the following **Options**:

* *width* - Explicit width for the chart (overrides auto-fit to container width)
* *height* - Explicit height for the chart (overrides auto-fix to container height)
* *margins* - Explicit margin overrides for the chart. Example: `{ top: 50, right: 30, bottom: 100, left: 40 }`
* *axes* - Which axes to display. Example: `['top', 'right', 'bottom', 'left']`
* *ticks* - Number of ticks to display on each axis. Example: `{ top: 10, right: 5, bottom: 20, left: 5 }`
* *tickFormats* - What formatting function to use when displaying tick labels. Ex: `{ bottom: function(v) { return '$' + v; } }`

And uses the following **Data Format**:

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

#### Pie

```html
<div id="pie" style="width: 400px; height: 400px"></div>
<script>
  $('#pie').epoch({
    type: 'pie',
    data: chartData // Must follow the format as defined below...
  });
</script>
```

The Line chart has the following **Options**:

* *width* - Explicit width for the chart (overrides auto-fit to container width)
* *height* - Explicit height for the chart (overrides auto-fix to container height)
* *margin* - Margin size to surround the pie chart. Ex: `10`
* *inner* - Inner radius for the pie chart (for making Donut charts). Ex `100`

And uses the following **Data Format**:

```javascript
[
  { label: 'Slice 1', value: 10 },
  { label: 'Slice 2', value: 20 },
  { label: 'Slice 3', value: 40 },
  { label: 'Slice 4', value: 30 }
]
```

#### Scatter

```html
<div id="scatter" style="width: 800px; height: 200px"></div>
<script>
  $('#scatter').epoch({
    type: 'scatter',
    data: chartData // Must follow the format as defined below...
  });
</script>
```

The Scatter chart has the following **Options**:

* *width* - Explicit width for the chart (overrides auto-fit to container width)
* *height* - Explicit height for the chart (overrides auto-fix to container height)
* *margins* - Explicit margin overrides for the chart. Example: `{ top: 50, right: 30, bottom: 100, left: 40 }`
* *axes* - Which axes to display. Example: `['top', 'right', 'bottom', 'left']`
* *ticks* - Number of ticks to display on each axis. Example: `{ top: 10, right: 5, bottom: 20, left: 5 }`
* *tickFormats* - What formatting function to use when displaying tick labels. Ex: `{ bottom: function(v) { return '$' + v; } }`

And uses the following **Data Format**:

```javascript
[
  // The first group
  {
    label: "Group 1",
    values: [ {x: 0, y: 100}, {x: 20, y: 1000}, ... ]
  },

  // The second group
  {
    label: "Group 2",
    values: [ {x: 0, y: 78}, {x: 20, y: 98}, ... ]
  },

  // Add as many as you would like!
]
```



### Real-time Charts

Epoch's **real-time** charts have been fine tuned for displaying frequently updating *timeseries* data. To make them performant (aka
not crash the browser) we've implemented the charts using a hybrid approach of d3 SVG with custom HTML5 Canvas rendering. This section
details each of the real-time charts in detail.

#### Area

#### Bar

#### Gauge

#### Heatmap

#### Line


### Developing Epoch

To work on the epoch charting library itself do the following:

1. Clone the repository
2. Install the npm package `node-minify`; `npm install -g node-minify`, then `npm link node-minify`. 
2.2 `npm install -g codo` - Documentation (CLEAN ME UP)
3. Run `cake build` from the project directory
4. View `docs/static.html` and `docs/time.html` for a quick overview of the available features
5. Scour the source for more detailed information (formal documentation coming soon)
6. Let cool and enjoy (serves millions).

