---
layout: default
title: Epoch - Getting Started
header-active: getting-started
root: ../
---

## Getting Started

1. [d3](https://github.com/mbostock/d3) and [jQuery](https://github.com/jquery/jquery) are required, so make sure you are including
them in your page.
2. Locate and download the `epoch.X.Y.Z.min.js` and `epoch.X.Y.Z.min.css` files in this repository, and place
them in your project (note: `X.Y.Z` is a placeholder for the current version of Epoch).
3. Include all the required JavaScript and CSS files into your source in the usual manner (probably in the head of the HTML document).
4. Read the examples and documentation below
5. Code, let cool, and enjoy (serves millions)

### A "quick & dirty" Introduction

Here are the basic steps you need to follow to create a multi-series area chart using Epoch:

**1) Include the appropriate scripts and styles**

```html
<head>
  <script src="js/jquery.min.js"></script>
  <script src="js/d3.min.js"></script>
  <script src="js/epoch.X.Y.Z.min.js"></script>
  <link rel="stylesheet" type="text/css" href="css/epoch.X.Y.Z.min.css">
</head>
```

**2) Create the a container div for the chart**

```html
<div id="area" class="category10" style="width: 700px; height: 200px;"></div>
```

* Epoch will size the chart to fix the explicit dimensions of the container
* The class name "category10" refers to the categorical color scheme to use
  when rendering the chart. Other options are `category20` (default), 
  `category20b`, and `category20c`. See the 
  [d3 categorical color docs](https://github.com/mbostock/d3/wiki/Ordinal-Scales#categorical-colors)
  for more information.

**3) Setup the chart's data**

```javascript
var data = [
  { label: 'Layer 1', values: [ {x: 0, y: 0}, {x: 1, y: 1}, {x: 2, y: 2} ] },
  { label: 'Layer 2', values: [ {x: 0, y: 0}, {x: 1, y: 1}, {x: 2, y: 4} ] }
];
```

* Each chart type expects a certain data format. For the most part they are very similar to
  the example given above. Some types of charts (e.g. pie, guage, heatmap) require rather
  different formats. Make sure to read the chart-by-chart documentation below to see exactly
  what each type expects.

**4) Initialize, place, and draw the chart**

```javascript
var areaChartInstance = $('#area').epoch({ type: 'area', data: data });
```

* We use custom jQuery method `.epoch` to create the chart. It will automatically place it as child
  of the our container div and size it to fill the div completely.
* The `.epoch` function returns a programming interface with with to interact with the chart
  (in this example it is assigned to the `areaChartInstance` variable). For basic charts such as
  this it is used to update the chart's data, for example: `areaChartInstance.update(myNewData);`.

### Visual Styles

Epoch charts use CSS to set fill colors, strokes, etc. By default charts are colored using
[d3 categorical color](https://github.com/mbostock/d3/wiki/Ordinal-Scales#categorical-colors). You can easily override
these default colors or create your own custom categories.

#### Using Categorical Colors

We support the following categorical color sets:

* `category20` (default)
* `category20b`
* `category20c`
* `category10`

You can change a chart's color set by simply adding a class to the chart, like so:

```html
<div id="container1" class="epoch category20"></div>
<div id="container1" class="epoch category20b"></div>
<div id="container1" class="epoch category20c"></div>
<div id="container1" class="epoch category10"></div>
```

We achieve this by adding a category class to each element in a chart that needs to be rendered using the categorical color.

#### Creating Your Own Categories

The preferred method for doing this would be to use a css preprocessor like Sass or Less, here's an example of a simple color
scheme as written in SCSS:

```scss
$colors: red, green, blue, pink, yellow;

.epoch.my-colors {
  @for $i from 1 through 5 {
    .category#{$i} {
      .line { stroke: nth($colors, $i); }
      .area, .dot { fill: nth($colors, $i); }
    }
    .arc.category#{$i} path {
      fill: nth($colors, $i);
    }
    .bar.category#{$i} { 
      fill: nth($colors, $i);
    }
  }
}
```

You could then apply the class to your containers and see your colors in action:

```html
<div id="myChart" class="epoch my-colors"></div>
```

In the future we will be creating SCSS and LESS plugins with mixins you can use to more easily define custom color categories.


#### Specific Overrides

For multi-series charts, the data format requires that you supply a `label` for each series. We create a "dasherized"
class name from this label and associate it with the rendered output of the chart. For instance, take the following
data for an area chart:

```javascript
var areaChartData = [
  {
    label: "Layer 1",
    values: [ {x: 0, y: 100}, {x: 20, y: 1000} ]
  }
];
```

The layer labeled `Layer 1` will be associated in the chart with the class name `layer-1`. To override it's color simply
use the following CSS:

```css
#myChartContainer .layer-1 .area {
  fill: pink;
}
```
