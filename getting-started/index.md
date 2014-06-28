---
layout: default
title: Epoch - Getting Started
header-active: getting-started
---

## Getting Started

This page will help you get started using Epoch in your projects.

### Prerequisites

After [downloading epoch]({{ site.baseurl }}download/epoch.{{ site.version }}.zip) you'll need to setup your page so you can generate charts. First, epoch has two external library requirements:

1. [jQuery](https://github.com/jquery/jquery)
2. [d3](https://github.com/mbostock/d3)

These scripts must be loaded before adding Epoch into your page, like so:

```html
<script src="js/jquery.min.js"></script>
<script src="js/d3.min.js"></script>
<script src="js/epoch.X.Y.Z.min.js"></script>
```

Finally you'll need to include the Epoch CSS in the page's head section:

```html
<link rel="stylesheet" type="text/css" href="css/epoch.X.Y.Z.min.css">
```

At this point you're ready to start using Epoch to build and place charts in your application.


### Building a Chart

Building a chart using epoch is a snap and each type of chart follows the same basic workflow. In this section we will run through the steps you'll use when adding charts to your pages.

#### 1. Place a chart container in the page

```html
<div id="area" class="epoch category10" style="height: 200px;"></div>
```

Epoch will automatically size the chart to fit the explicit dimensions of the container. This way you can build the basic layout of your site and use CSS to control the size and placement of the charts. The class name `category10` refers to the categorical color scheme to use when rendering the chart. There are three other default options you can use, namely: `category20`, `category20b`, and `category20c`. Categorical colors are based directly on those used by d3, for more information see the [d3 categorical color docs](https://github.com/mbostock/d3/wiki/Ordinal-Scales#categorical-colors).


#### 2. Format your Data

```javascript
var data = [
  { label: 'Layer 1', values: [ {x: 0, y: 0}, {x: 1, y: 1}, {x: 2, y: 2} ] },
  { label: 'Layer 2', values: [ {x: 0, y: 0}, {x: 1, y: 1}, {x: 2, y: 4} ] }
];
```

Each chart type expects a certain data format. For the most part they are very similar to the example given above. Some types of charts (e.g. pie, guage, heatmap) require rather different formats. Make sure to read the chart-by-chart documentation below to see exactly what each chart expects.

#### 3. Initialize, Place, and Draw

```javascript
var areaChartInstance = $('#area').epoch({ type: 'area', data: data });
```

Use the custom jQuery method `.epoch` to create the chart. The method will automatically insert the chart as a direct child of the selected container (in this case the `div` with an id of `area`). After the elements have been placed the method will resize the chart to completely fill the container and draw the chart based on the data it was given.

The `.epoch` function returns a chart class instance that can be used to interact with the chart post initialization. In the example above we keep a reference to the chart instance in the `areaChartInstance` variable. For basic charts, such at the area chart we created, this instance can be used to update the chart's data via the `update` method.


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

For multi-series charts, the data format lets your supply an optional `label` for each series. We create a "dasherized"
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
