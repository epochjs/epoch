## Epoch - The Fastly Charting Library
By Ryan Sandor Richards

### Introduction


Back in 2011 we built some pretty sweet real-time visualizations for our web based analytics dashboard here at Fastly. They were built to be performant (use as little CPU as possible), efficient (not be memory hogs), and consistent (you can keep them up 24 hours a day, seven days a week). Recently we began expanding our internal tools and it became necessary for us to add charting and reporting across many different applications. Enter Epoch.

With Epoch we rewrote those original visualizations from the ground up and constructed a framework atop which any reasonably kick-ass visualization can be realized. Epoch was also built to be extensible by abstracting away common graphing and charting procedures (scales, axes, ticks, etc.).

The result is a simple to use library for application developers, and a powerful framework for charting and reporting designers.


### Prerequisites

Epoch requires the following libraries in order to work:

1. [d3](https://github.com/mbostock/d3)
2. [jQuery](https://github.com/jquery/jquery)

### Quick Example

First, examine this example bandwidth data and how it is formatted:

```
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

```
var barChart = $('div#bar').epoch({
  type: 'time.bar',
  data: bandwidthData
});
```

The chart is automatically sized to fit the containing div (`div#bar`) and the data is rendered to the page immediately. The jQuery method
`.epoch` returns a chart instance which we assign to the variable `barChart`. At this point we can setup a simple poll to for new information
from our stats servers and get the graph updating in real time. Here's an example of how one might do this:

```
function pollBandwidthData() {
  $.get('/stats/bandwidth', function(data) {
    barChart.push(data);
  })
}

setInterval(pollBandwidthData, 1000);
```

Upon calling the `push` method the new data will be added to the visualization and an animated transition will begin.



### Using Epoch

To use epoch to perform charting in your project, do the following:

1. Place the versioned `epoch.X.Y.Z.min.js` file in your project and load it in your page.
2. Place the `css/epoch.css` in your project and include it in a link reference.


### Developing Epoch

To work on the epoch charting library itself do the following:

1. Clone the repository
2. Install the npm package `node-minify`; `npm install -g node-minify`, then `npm link node-minify`. 
2.2 `npm install -g codo` - Documentation (CLEAN ME UP)
3. Run `cake build` from the project directory
4. View `docs/static.html` and `docs/time.html` for a quick overview of the available features
5. Scour the source for more detailed information (formal documentation coming soon)
6. Let cool and enjoy (serves millions).

