## Epoch - The Fastly Charting Library
By Ryan Sandor Richards

### Introduction

Epoch is a general purpose charting library for application developers and visualization designers. It focuses on two different aspects of
visualization programming: **static charts** for creating historical reports, and **real-time charts** for displaying frequently 
updating timeseries data.

### Getting Started

1. [d3](https://github.com/mbostock/d3) and [jQuery](https://github.com/jquery/jquery) are required, so make sure you are including
them in your page.
2. Locate and download the `epoch.X.Y.Z.min.js` and `epoch.X.Y.Z.min.css` files in this repository, and place
them in your project (note: `X.Y.Z` is a placeholder for the current version of Epoch).
3. Include all the required JavaScript and CSS files into your source in the usual manner (probably in the head of the HTML document).
4. Read the examples and documentation below
5. Code, let cool, and enjoy (serves millions)


### Static Charts

Epoch's **Static** charts are implemented using d3 over a thin class hieracrchy. The classes perform common tasks (such as setting up
scales, axes, etc.) while the individual charts implement their own specialized drawing routines. 

Every static chart was built to use the same basic workflow, here's an overview:

1. Create an HTML container.
  - Epoch automagically sizes charts to fit their containers.
  - `<div id="myChart" style="width: 200px; height: 200px"></div>`
2. Fetch and format your data.
  - Each type of chart uses a specific (though often familiar) data format.
  - See the documentation below for how each chart is expecting the data.
3. Use the jQuery method `.epoch` to create, append, and draw the chart.
  - `var myChart = $('#myChart').epoch({ type: 'line', data: myData });`
4. When you data changes, simply use the `update` method on the chart instance.
  - `myChart.update(myNewData)`

The rest of this section explains the individual charts in detail.


#### area

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
d3 to make the best looking graphs possible. To create a single series plot simply include a single layer.

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

In the `<script>` portion of the example above you'll notice that we are passing options to the `.epoch` method. The following
options are available for `type: area` epoch charts:

* `width` - Override automatic width with an explicit pixel value
  - Example: `width: 320`
* `height` - Override automatic height with an explicit pixel value
  - Example: `height: 240`
* `margins` - Explicit margin overrides for the chart.
  - Example: `margins: { top: 50, right: 30, bottom: 100, left: 40 }`
* `axes` - Which axes to display.
  - Example: `axes: ['top', right', 'bottom', 'left']`
* `ticks` - Number of ticks to display on each axis.
  - Example: `{ top: 10, right: 5, bottom: 20, left: 5 }`
* `tickFormats` - What formatting function to use when displaying tick labels.
  - Example: `tickFormats: { bottom: function(d) { return '$' + d.toFixed(2); } }`


#### bar

Epoch's implementation of a multi-series grouped bar chart. Bar charts are useful for showing data by group over a discrete
domain. First, let's look at how the data is formatted for a bar chart:

```javascript
var barChartData = [
  // First bar series
  {
    label: 'Series 1',
    values: [
      { x: 'A', y: 30 },
      { x: 'B', y: 10 },
      { x: 'C', y: 12 },
      ...
    ]
  }

  // Second series
  {
    label: 'Series 2',
    values: [
      { x: 'A', y: 20 },
      { x: 'B', y: 39 },
      { x: 'C', y: 8 },
      ...
    ]
  },

  ... // Add as many series as you'd like
];
```

The bar chart will create groups of bars that share a like `x` value for each independent value present in the data. Currently
only grouped bar charts are available but we're planning on adding *stacked* and *normalized stacked* charts soon!

Next, let's take a look at the markup and scripting required to display our bar data:

```html
<div id="barChart" style="width: 300px; height: 100px"></div>
<script>
  $('#barChart').epoch({
    type: 'bar',
    data: barChartData
  });
</script>
```

The chart will automatically be sized to it's containing element (in this case to 300px x 100px). 

In the `<script>` portion of the example above you'll notice that we are passing options to the `.epoch` method. The following
options are available for `type: area` epoch charts:

* `width` - Override automatic width with an explicit pixel value
  - Example: `width: 320`
* `height` - Override automatic height with an explicit pixel value
  - Example: `height: 240`
* `margins` - Explicit margin overrides for the chart.
  - Example: `margins: { top: 50, right: 30, bottom: 100, left: 40 }`
* `axes` - Which axes to display.
  - Example: `axes: ['top', right', 'bottom', 'left']`
* `ticks` - Number of ticks to display on each axis.
  - Example: `{ top: 10, right: 5, bottom: 20, left: 5 }`
* `tickFormats` - What formatting function to use when displaying tick labels.
  - Example: `tickFormats: { bottom: function(d) { return '$' + d.toFixed(2); } }`


#### line

Line charts are helpful for visualizing single or multi-series data when without stacking or shading. To begin, let's take a look
at the data format used by epoch's line chart:

```javascript
var lineChartData = [
  // The first series
  {
    label: "Series 1",
    values: [ {x: 0, y: 100}, {x: 20, y: 1000}, ... ]
  },

  // The second series
  {
    label: "Series 2",
    values: [ {x: 20, y: 78}, {x: 30, y: 98}, ... ]
  },

  ... // Add as many series as you would like
];
```

Notice that the data is very similar to that of the area chart above, with the exception that they need not cover the same domain
nor do the entries in each series have to line up via the `x` coordinate.

Next let's take a look at how you would implement the chart with markup and scripting:

```html
<div id="lineChart" style="width: 700px; height: 250px"></div>
<script>
  $('#lineChart').epoch({
    type: 'line',
    data: lineChartData
  });
</script>
```

The chart will be automatically sized to that of it's containing element (in this case 700px by 250px). Along with the
`type` and `data` options, Epoch line charts support the following:

* `width` - Override automatic width with an explicit pixel value
  - Example: `width: 320`
* `height` - Override automatic height with an explicit pixel value
  - Example: `height: 240`
* `margins` - Explicit margin overrides for the chart.
  - Example: `margins: { top: 50, right: 30, bottom: 100, left: 40 }`
* `axes` - Which axes to display.
  - Example: `axes: ['top', right', 'bottom', 'left']`
* `ticks` - Number of ticks to display on each axis.
  - Example: `{ top: 10, right: 5, bottom: 20, left: 5 }`
* `tickFormats` - What formatting function to use when displaying tick labels.
  - Example: `tickFormats: { bottom: function(d) { return '$' + d.toFixed(2); } }`


#### Pie

Pie charts are useful for displaying the relative sizes of various categories. To begin, let's take a look at the data format
used by Epoch's pie chart implementation:


```javascript
var pieData = [
  { label: 'Slice 1', value: 10 },
  { label: 'Slice 2', value: 20 },
  { label: 'Slice 3', value: 40 },
  { label: 'Slice 4', value: 30 }
]
```

The data itself is an array of objects that represent the slices in the pie chart. The `label` parameter will be used to set
the label for the slice in the chart and the `value` parameter will be used to determine its visual size in comparison to the
other slices.

Once you have your data formatted correctly you can easly add a chart to your page using the following markup and script:

```html
<div id="pie" style="width: 400px; height: 400px"></div>
<script>
  $('#pie').epoch({
    type: 'pie',
    data: pieData
  });
</script>
```

The chart will be appended to the containing div and automatically sized to fit its dimensions (in this case 400px by 400px). The pie
chart also accepts the following parameters during initialization:

* `width` - Override automatic width with an explicit pixel value
  - Example: `width: 320`
* `height` - Override automatic height with an explicit pixel value
  - Example: `height: 240`
* `margin` - Surrounds the chart with a defined pixel margin
  - Example: `margin: 30`
* `inner` - Inner radius for the pie chart (for making Donut charts)
  - Example: `inner: 100`


#### Scatter

Scatter plots are useful for visualizing statistical or sampling data in hopes of revealing patterns. To begin let's take a look at the
data format used by scatter plots:

```javascript
var scatterData = [
  // The first group
  {
    label: "Group 1",
    values: [ {x: 5, y: 100}, {x: 93, y: 1424}, ... ]
  },

  // The second group
  {
    label: "Group 2",
    values: [ {x: -52, y: 78}, {x: 120, y: 17}, ... ]
  },

  ...
];
```

The data is composed of an array containing "groups" of points. Groups need not have the same number of values nor do they
have to match the same `x` coordinate domains.

Next, let's see the markup and scripting needed to add the plot to your page:

```html
<div id="scatter" style="width: 500px; height: 500px"></div>
<script>
  $('#scatter').epoch({
    type: 'scatter',
    data: scatterData
  });
</script>
```

The plot will be added as an element to the `#scatter` div and be automatically sized to fit its dimensions (in this case
500px by 500px). Epoch scatter plots can be passed a few different parameters to change their appearance and rendering,
they are:

* `radius` - How large the "dots" should be in the plot (in pixels)
  - Example: `radius: 4.5`
* `width` - Override automatic width with an explicit pixel value
  - Example: `width: 320`
* `height` - Override automatic height with an explicit pixel value
  - Example: `height: 240`
* `margins` - Explicit margin overrides for the chart.
  - Example: `margins: { top: 50, right: 30, bottom: 100, left: 40 }`
* `axes` - Which axes to display.
  - Example: `axes: ['top', right', 'bottom', 'left']`
* `ticks` - Number of ticks to display on each axis.
  - Example: `{ top: 10, right: 5, bottom: 20, left: 5 }`
* `tickFormats` - What formatting function to use when displaying tick labels.
  - Example: `tickFormats: { bottom: function(d) { return '$' + d.toFixed(2); } }`


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

