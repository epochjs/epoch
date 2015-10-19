## Epoch
By Ryan Sandor Richards

[![Build Status](https://travis-ci.org/epochjs/epoch.svg?branch=master)](https://travis-ci.org/epochjs/epoch)
[![Dependency Status](https://david-dm.org/epochjs/epoch.svg)](https://david-dm.org/epochjs/epoch)
[![devDependency Status](https://david-dm.org/epochjs/epoch/dev-status.svg)](https://david-dm.org/epochjs/epoch#info=devDependencies)

Epoch is a general purpose charting library for application developers and visualization designers. It focuses on two different aspects of visualization programming: **basic charts** for creating historical reports, and **real-time charts** for displaying frequently updating timeseries data.

To get started using Epoch, please refer to the [Epoch Project Site](http://epochjs.github.io/epoch/). There you can find full documentation and guides to help you start using Epoch right away.

### Installation
Epoch can be easily installed via the following package managers:

* [npm](https://www.npmjs.com/package/epoch-charting)
* [bower](http://bower.io/search/?q=epoch)
* [packagist](https://packagist.org/packages/epochjs/epoch)

If you don't see your favorite package manager in the list above feel free to
[open up an issue](https://github.com/epochjs/epoch/issues/new) and let us know.
Finally, you can download any release of the library from the
[project releases page](https://github.com/epochjs/epoch/releases).

**Important:** Epoch requires [d3](https://github.com/mbostock/d3). In order to
work properly your page must load d3 before epoch.

#### Public CDN URLs
If you don't want to host the files yourself, you can use
[jsDelivr](http://http://www.jsdelivr.com/) to serve the files:

1. Visit [epoch page on jsDelvr](http://www.jsdelivr.com/projects/epoch).
2. Copy the provided URL's and link to them in your project.

### Developing Epoch

Developing Epoch is a reasonably straight forward process. In this section we'll
cover the basic on how to develop Epoch by detailing common build task, exploring
how the source is arranged, and finally show how to use rendering tests to aid
development.

#### Configuring Development Environment

Epoch requires the following for development:

1. [Node.js](https://nodejs.org/en/) (v4.1.1+)
2. [NPM](https://www.npmjs.com/) (v2.1.0+)

Once both are installed on your machine you will need to run `npm install` from
the repository's root directory in order to install the npm packages required
to develop epoch.

Once you have installed the required npm packages you can use `gulp build` to
fully rebuild the source (see more information about gulp tasks below).


#### Basic Development Process

The best way to start contributing to Epoch is to follow these steps:

1. Change to the source directory for the project
2. Run `gulp watch` to recompile the project after source files change
3. Make changes in a source file (either in `src/` or `sass/`)
4. In a web browser open the `test/index.html` and browse the rendering tests
5. Use the rendering tests to see if your changes had the desired result
6. Ensure unit tests with pass `npm test`

#### Testing

Epoch uses two types of testing to ensure that changes do not cause unintended
side effects. The first, unit tests, ensure that the core functional components
of the library work as expected. The second, rendering tests, allow you to
ensure that charts and graphs are correctly rendered.

It is important to keep both unit test and rendering tests up-to-date! When
developing, use the following guidelines:

* When adding new features make sure to add new tests
* When changing existing functionality, ensure that the appropriate both types
  of tests still pass
* If you want to make a new type of chart, add a whole new test suite for that
  chart!

Keeping the tests current makes it easier for others to review your code and
spot issues. Also, pull requests without appropriate testing will not be
merged.


#### Gulp Tasks

Epoch uses [gulp](https://github.com/gulpjs/gulp) to perform various tasks. The
`gulpfile.js` file defines the following tasks:

* `gulp clean` - Cleans the `dist/` directory.
* `gulp build` - Builds the CoffeeScript and Sass source into the `dist/`
  directory.
* `gulp watch` - Starts a watch script to recompile CoffeeScript and Sass when
  any files change.

#### Source Structure

The directory structure for the Epoch project follows some basic guidelines, here's an overview of how it is structured:

```
dist/                  - Compiled JavaScript and CSS source
src/                   - Main source directory
  core/                - Core Epoch Library Files
    util.coffee        - Library Utility Routines
    d3.coffee          - d3 Extensions
    format.coffee      - Data formatters
    chart.coffee       - Base Chart Classes
    css.coffee         - CSS Querying Engine
  adapters/            - 3rd Party Library Adapters (currently only jQuery)
  basic/               - Basic Chart Classes
  time/                - Real-time Chart Classes
  adapters.coffee      - Options / Global Classes for Adapter Implementations
  basic.coffee         - Base Classes for Basic Charts
  data.coffee          - Data Formatting
  epoch.coffee         - Main source file, defines name spaces, etc.
  model.coffee         - Data Model
  time.coffee          - Base Classes for Real-Time Charts
sass/                  - Scss source for the default epoch stylesheet
tests/
  render/              - Rendering tests
    basic/             - Basic chart rendering tests
    real-time/         - Real-time rendering tests
  unit/                - Unit tests
```

### Release Checklist

- Run `npm test` and ensure all tests pass
- Run `npm version [major|minor|patch]`
- Run `npm publish`
- Update CHANGELOG.md with the changes since last release
- Update the `gh-pages` branch's library version in `_config.yml`
