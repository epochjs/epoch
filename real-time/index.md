---
layout: docs
title: Basic Charts
nav: nav/realtime.html
banner: banner/real-time.html
header-active: real-time
---
## Real-time

Epoch's **real-time** charts have been fine tuned for displaying frequently updating *timeseries* data. To make them performant (aka not crash the browser) we've implemented the charts using a hybrid approach of d3 SVG with custom HTML5 Canvas rendering.

### Overview

Every real-time chart has a name prefixed with `time.` and was built to use the same workflow, here's an overview:

1. Create an HTML container.
  - Epoch automagically sizes charts to fit their containers.
  - `<div id="myChart" style="width: 200px; height: 200px"></div>`
2. Fetch and format your data.
  - Each type of chart uses a specific (though often familiar) data format.
  - See the documentation below for how each chart is expecting the data.
3. Use the jQuery method `.epoch` to create, append, and draw the chart.
  - `var myChart = $('#myChart').epoch({ type: 'time.line', data: myData });`
4. When you have a new data point to append to the chart, use the `.push` method:
  - `myChart.push(nextDataPoint);`


#### Device Pixel Ratio

Epoch supports high resolution displays by automatically detecting and setting the appropriate pixel ratio for the canvas based real-time charts. You can override this behavior by explicitly setting the pixel ratio for any chart described below. Here's an example of how to do this:

```javascript
$('#my-chart').epoch({
  type: 'time.line',
  pixelRatio: 1
})
```

Note that the `pixelRatio` option must be an integer >= 1.


#### Common Options

Unless otherwise stated, Epoch's real-time charts have the following common options:

<table class="table table-bordered table-striped">
  <tr>
    <th>Name</th>
    <th>Description</th>
  </tr>
  <tr>
    <td><code>axes</code></td>
    <td>
      Which axes to display.<br>
      <i>Example:</i> <code>axes: ['top', 'right', 'bottom', 'left']</code></td>
  </tr>
  <tr>
    <td><code>ticks</code></td>
    <td>
      Number of ticks to display on each axis.<br>
      <i>Example:</i> <code>{ time: 10, right: 5, left: 5 }</code></td>
  </tr>
  <tr>
    <td><code>tickFormats</code></td>
    <td>
      What formatting function to use when displaying tick labels.<br>
      <i>Example:</i> <code>tickFormats: { time: function(d) { return new Date(time*1000).toString(); } }</code></td>
  </tr>
  <tr>
    <td><code>fps</code></td>
    <td>
      Number of frames per second that transitions animations should use. For most people, frame rates in excess of 60fps inpeceptible and can cause a big performance hit. The default value of <code>24</code> tends to work very well, but you can increase it to get smoother animations.<br>
      <i>Example:</i> <code>fps: 60</code></td>
  </tr>
  <tr>
    <td><code>windowSize</code></td>
    <td>
      Number of entries to display in the graph.<br>
      <i>Example:</i> <code>windowSize: 60</code></td>
  </tr>
  <tr>
    <td><code>historySize</code></td>
    <td>
      Maximum number of historical entries to track in the chart.<br>
      <i>Example:</i> <code>historySize: 240</code></td>
  </tr>
  <tr>
    <td><code>queueSize</code></td>
    <td>
      Number of entries to keep in working memory while the chart is not animating transitions. Some browsers will not run animation intervals if a tab is inactive. This parameter allows you to bound the number of entries that have been recieved via the `.push` in this case (so as to reduce memory bloating).<br>
      <i>Example:</i> <code>queueSize: 120</code></td>
  </tr>
  <tr>
    <td><code>margins</code></td>
    <td>
      Explicit margin overrides for the chart.<br>
      <i>Example:</i> <code>margins: { top: 50, right: 30, bottom: 100, left: 40 }</code></td>
  </tr>
  <tr>
    <td><code>width</code></td>
    <td>
      Override automatic width with an explicit pixel value.<br>
      <i>Example:</i> <code>width: 320</code></td>
  </tr>
  <tr>
    <td><code>height</code></td>
    <td>
      Override automatic height with an explicit pixel value.<br>
      <i>Example:</i> <code>height: 240</code></td>
  </tr>
  <tr>
    <td><code>pixelRatio</code></td>
    <td>
      Override detected pixel ratio with an explicit value.<br>
      <i>Example:</i> <code>pixelRatio: 1</code></td>
  </tr>
</table>


{% include charts/realtime/area.html %}

The real-time area chart works in a very similar way to the basic area chart detailed above. It is used to show relative sizes of
multi-series data as it evolves over time.

```javascript
var areaChartData = [
  // The first layer
  {
    label: "Layer 1",
    values: [ {time: 1370044800, y: 100}, {time: 1370044801, y: 1000}, ... ]
  },

  // The second layer
  {
    label: "Layer 2",
    values: [ {time: 1370044800, y: 78}, {time: 1370044801, y: 98}, ... ]
  },

  ...
];
```

As you can see the data is arranged as an array of layers. Each layer is an object that has the following properties:

* `label` - The name of the layer
* `values` - An array of values each value having a unix timestamp (`time`) and a value at that time (`y`)

The real-time chart requires that values in each layer have the exact same number of elements and that each corresponding
entry have the same `time` value.

Given that you have data in the appropriate format, instantiating a new chart is fairly easy. Simply create a container
element in HTML and use the jQuery bindings to create, place, and draw the chart:

```html
<div id="areaChart" style="width: 800px; height: 200px"></div>
<script>
  $('#areaChart').epoch({
    type: 'time.area',
    data: areaChartData
  });
</script>
```

{% include charts/realtime/bar.html %}

The real-time bar chart is used to show relative sizes of multi-series data in the form of *stacked bars* as it evolves over time.

```javascript
var barChartData = [
  // First series
  {
    label: "Series 1",
    values: [ {time: 1370044800, y: 100}, {time: 1370044801, y: 1000}, ... ]
  },

  // The second series
  {
    label: "Series 2",
    values: [ {time: 1370044800, y: 78}, {time: 1370044801, y: 98}, ... ]
  },

  ...
];
```

As you can see the data is arranged as an array of layers. Each layer is an object that has the following properties:

* `label` - The name of the layer
* `values` - An array of values each value having a unix timestamp (`time`) and a value at that time (`y`)

The real-time chart requires that values in each layer have the exact same number of elements and that each corresponding
entry have the same `time` value.

Given that you have data in the appropriate format, instantiating a new chart is fairly easy. Simply create a container
element in HTML and use the jQuery bindings to create, place, and draw the chart:

```html
<div id="barChart" style="width: 800px; height: 200px"></div>
<script>
  $('#barChart').epoch({
    type: 'time.bar',
    data: barChartData
  });
</script>
```

{% include charts/realtime/gauge.html %}

The gauge chart is used to monitor values over a particular range as they change over time. The chart displays a gauge that is similar to
an automobile speedometer.

Unlike most Epoch charts the time gauge does not accept a `data` parameter upon initialization. Instead it has no *memory* and only knows
about its current `value`.

The real-time gauge chart is also programmed to fit a **specific aspect ratio** (4:3). To aid programmers we have included a few css
classes you can use to automatically size the chart:

* `gauge-tiny` (120px by 90px)
* `gauge-small` (180px by 135px)
* `gauge-medium` (240px by 180px)
* `gauge-large` (320px by 240px)

You do not have to use these classes, but you must ensure that your chart container is constrained to the 4 to 3 aspect ratio in order
for the chart to render correctly. Let's take a look at how one might create a new gauge chart:

```html
<div id="gaugeChart" class="epoch gauge-small"></div>
<script>
  $('#gaugeChart').epoch({
    type: 'time.gauge',
    value: 0.5
  });
</script>
```

#### Options

The guage chart implements the following common options:

* `fps` - Animation frames per second.
* `pixelRatio` - Explicit pixel ratio override.

And has follow custom options:

<table class="table table-bordered table-striped">
  <tr>
    <th>Name</th>
    <th>Description</th>
  </tr>
  <tr>
    <td><code>domain</code></td>
    <td>
      The input domain when setting the value for the gauge chart. Essentially this is an array with the first element representing the minimum value to expect and the second element representing the maximum.<br>
      <i>Example:</i> <code>domain: [0, 1]</code></td>
  </tr>
  <tr>
    <td><code>ticks</code></td>
    <td>
      Number of tick marks to display on the chart.<br>
      <i>Example:</i> <code>ticks: 10</code></td>
  </tr>
  <tr>
    <td><code>tickSize</code></td>
    <td>
      Size in pixels for each tick.<br>
      <i>Example:</i> <code>tickSize: 5</code></td>
  </tr>
  <tr>
    <td><code>tickOffset</code></td>
    <td>
      Number of pixels to offset ticks by from the outter arc of the gauge.<br>
      <i>Example:</i> <code>tickOffset: 10</code></td>
  </tr>
  <tr>
    <td><code>format</code></td>
    <td>
      The number formatter to use for the gauge's internal display label.<br>
      <i>Example:</i> <code>format: function(v) { return (v*100).toFixed(2) + '%'; }</code></td>
  </tr>
</table>


{% include charts/realtime/heatmap.html %}

The real-time heatmap chart is used to visualize normalized histogram data over time. It works by first sorting incoming histograms
into a small set of discrete buckets. For multi-series data it uses color blending to show series concentration.

This type of chart has the most "intense" data format, with each entry expecting a sparse histogram. Let's examine this format using
and example:

```javascript
var heatmapData = [
  // First Series
  {
    label: 'Series 1',
    values: [
      {
        time: 1370044800,
        histogram: {
          18: 49,
          104: 10,
          ...
        }
      },

      {
        time: 1370044801,
        histogram: {
          9: 8,
          120: 17,
          ...
        }
      },
    ]
  },

  ...
];
```

As you can see the data is arranged as an array of layers. Each layer is an object that has the following properties:

* `label` - The name of the layer
* `value` - A list of unix timestamp associated sparse histograms:
  - `time` - The unix timestam for the entry
  - `histogram` - A "sparse" frequency hash that maps values to frequencies

Given that you have data in the appropriate format, instantiating a new chart is fairly easy. Simply create a container
element in HTML and use the jQuery bindings to create, place, and draw the chart:

```html
<div id="heatmapChart" style="width: 800px; height: 200px"></div>
<script>
  $('#heatmapChart').epoch({
    type: 'time.heatmap',
    data: heatmapData
  });
</script>
```

#### Options

In addition to the common options listed in the overview section, the heatmap has the following custom options:


<table class="table table-bordered table-striped">
  <tr>
    <th>Name</th>
    <th>Description</th>
  </tr>
  <tr>
    <td><code>buckets</code></td>
    <td>
      Number of buckets to display in each column of the visible chart window.<br>
      <i>Example:</i> <code>buckets: 20</code></td>
  </tr>
  <tr>
    <td><code>bucketRange</code></td>
    <td>
      The range covered by the buckets. Note: values that fall above the range will be placed in the top most bucket, and values that fall below the range will be placed in the bottom must bucket.<br>
      <i>Example:</i> <code>bucketRange: [0, 1000]</code></td>
  </tr>
  <tr>
    <td><code>bucketPadding</code></td>
    <td>
      Amount of padding to place around buckets in the display.<br>
      <i>Example:</i> <code>bucketPadding: 0</code></td>
  </tr>
  <tr>
    <td><code>opacity</code></td>
    <td>
      The opacity function to use when rendering buckets.
      <ul>
        <li>Each bucket will be rendered using a specific opacity. More saturated colors represent higher values in
    histogram and more transparent colors represent lower values.</li>
        <li>There are many built-in opacity functions: `root`, `linear`, `quadratic`, `cubic`, `quartic`, and `quintic`.</li>
        <li>You can define your own custom function, see the example below.</li>
      </ul>
      <i>Example:</i> <code>opacity: function(value, max) { return Math.pow(value/max, 0.384); }</code></td>
  </tr>
  <tr>
    <td><code>paintZeroValues</code></td>
    <td>
      Tells the chart whether or not to skip rendering entirely for buckets that have a value of 0, defaults to <code>false</code>. This is useful for overrding the default behavior of the chart when implementing different custom <a href="http://en.wikipedia.org/wiki/Choropleth_map#Color_progression" target="_blank">color progressions</a>.<br>
      <i>Example:</i> <code>paintZeroValues: true</code></td>
  </tr>
</table>


{% include charts/realtime/line.html %}

The real-time line chart is used to display multi-series data as it changes over time. To begin, the chart uses the following
data format:

```javascript
var lineChartData = [
  // First series
  {
    label: "Series 1",
    values: [ {time: 1370044800, y: 100}, {time: 1370044801, y: 1000}, ... ]
  },

  // The second series
  {
    label: "Series 2",
    values: [ {time: 1370044800, y: 78}, {time: 1370044801, y: 98}, ... ]
  },

  ...
];
```

As you can see the data is arranged as an array of layers. Each layer is an object that has the following properties:

* `label` - The name of the layer
* `values` - An array of values each value having a unix timestamp (`time`) and a value at that time (`y`)

The real-time chart requires that values in each layer have the exact same number of elements and that each corresponding
entry have the same `time` value.

Given that you have data in the appropriate format, instantiating a new chart is fairly easy. Simply create a container
element in HTML and use the jQuery bindings to create, place, and draw the chart:

```html
<div id="lineChart" style="width: 800px; height: 200px"></div>
<script>
  $('#lineChart').epoch({
    type: 'time.bar',
    data: lineChartData
  });
</script>
```
