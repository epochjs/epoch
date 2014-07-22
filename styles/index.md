---
layout: docs
title: Epoch - CSS
header-active: css
nav: nav/css.html
---

<h2 id="overview">CSS</h2>

Epoch charts use CSS to set fill colors, strokes, etc. By default charts are colored using
[d3 categorical color](https://github.com/mbostock/d3/wiki/Ordinal-Scales#categorical-colors). You can easily override
these default colors or create your own custom categories.

<h3 id="themes">Themes</h3>

Epoch arranges like styles for charts in the form of themes. Themes can be added to any HTML container via special class names. Currently, Epoch ships with two built-in themes:

1. `epoch-theme-default` - Default theme based on d3's categorical colors
2. `epoch-theme-dark` - A theme for use with dark backgrounds

Here's an example of how to use the class names, it's pretty simple:

```html
<body class="epoch-theme-dark">
    Charts in the body will use the dark theme...
    <div class="epoch-theme-default">Except charts here...</div>
</body>
```

Note: if no class name is given then epoch will assume the default theme.


<h3 id="colors">Using Categorical Colors</h3>

Each theme supports four categorical color sets: 

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


<h3 id="override">Overriding Styles</h3>

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
