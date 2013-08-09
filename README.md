## Epoch - The Fastly Charting Library
By Ryan Sandor Richards

### Introduction

Back in 2011 we built some pretty sweet real-time visualizations for our web based analytics dashboard here at Fastly. They were built to be performant (use as little CPU as possible), efficient (not be memory hogs), and consistent (you can keep them up 24 hours a day, seven days a week). Recently we began expanding our internal tools and it became necessary for us to add charting and reporting across many different applications. Enter Epoch.

With Epoch we rewrote those original visualizations from the ground up and constructed a framework atop which any reasonably kick-ass visualization can be realized. Epoch was also built to be extensible by abstracting away common graphing and charting procedures (scales, axes, ticks, etc.).

The result is a simple to use library for application developers, and a powerful framework for charting and reporting designers.


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

