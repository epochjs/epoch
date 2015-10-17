---
layout: default
title: Epoch - Getting Started
header-active: getting-started
---

## Getting Started

This page will help you get started using Epoch in your projects.

### Getting Epoch

Epoch can be installed from the following package managers:

* [npm](https://www.npmjs.com/package/epoch-charting)
* [bower](http://bower.io/search/?q=epoch)
* [packagist](https://packagist.org/packages/epochjs/epoch)

If you project does not use any of the package managers listed above you can
download the latest release of the library from the
[github repository release page](https://github.com/epochjs/epoch/archive/v{{ site.version }}.zip)
and install it manually into your project.

The release archives on github contain the entire source of Epoch. To use it in
your project you'll need to use the following files:

1. `dist/js/epoch.min.js`
2. `dist/css/epoch.min.css`


### Prerequisites

After installing epoch you'll need to setup your page so you can generate charts.
First, Epoch requires [d3](https://github.com/mbostock/d3), thus the scripts must
be added to your page like so:

```html
<script src="js/d3.min.js"></script>
<script src="js/epoch.min.js"></script>
```

Finally you'll need to include the Epoch CSS in the page's head section:

```html
<link rel="stylesheet" type="text/css" href="css/epoch.min.css">
```

At this point you're ready to start using Epoch to build and place charts in your application.


### Building a Chart

Building a chart using epoch is a snap and each type of chart follows the same basic workflow. In this section we will run through the steps you'll use when adding charts to your pages. For instance, let's build area chart, like this one:

<div id="area" class="epoch category10" style="height: 200px; margin: 40px 0;"></div>
<script>
(function() {
    var data = [
        { label: 'Layer 1', values: [ {x: 0, y: 0}, {x: 1, y: 1}, {x: 2, y: 2} ] },
        { label: 'Layer 2', values: [ {x: 0, y: 0}, {x: 1, y: 1}, {x: 2, y: 4} ] }
    ];
    $('#area').epoch({ type: 'area', data: data, axes: ['left', 'right', 'bottom'] });
})();

</script>

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
var areaChartInstance = $('#area').epoch({
    type: 'area',
    data: data,
    axes: ['left', 'right', 'bottom']
});
```

Use the custom jQuery method `.epoch` to create the chart. The method will automatically insert the chart as a direct child of the selected container (in this case the `div` with an id of `area`). After the elements have been placed the method will resize the chart to completely fill the container and draw the chart based on the data it was given.

The `.epoch` function returns a chart class instance that can be used to interact with the chart post initialization. In the example above we keep a reference to the chart instance in the `areaChartInstance` variable. For basic charts, such at the area chart we created, this instance can be used to update the chart's data via the `update` method.

### Changing Chart Options

Sometimes you will want to change the structural elements of charts based on user input and the like. To do so, each chart instance provides a special method named `.option`. The option method allows you to reset any of the options you passed during initialization and all of Epoch's default charts are built to react appropriately when options change.

The method can be used in the following ways:

1. `.option()` - Returns a deep copy of the chart's options
2. `.option(key)` - Returns a value for a given key
3. `.option(key, value)` - Sets an option with the given key to the given value
4. `.option(object)` - Sets key-value pairs in the given object as options for the chart

Note that all of the `key` strings can be hierarchical. For instance, you can use `.option('margins.left', 30)` to set the left margin, as opposed to having to use `.option({ margins: { left: 30 }})`.
