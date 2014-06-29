## Epoch
By Ryan Sandor Richards

### Introduction

Epoch is a general purpose charting library for application developers and visualization designers. It focuses on two different aspects of visualization programming: **basic charts** for creating historical reports, and **real-time charts** for displaying frequently updating timeseries data.

### Getting Started

To get started using Epoch, please refer to the [Epoch Project Site](http://fastly.github.io/epoch). There you can find full documentation and guides to help you start using Epoch right away.

#### Installing Epoch

There are two easy options you can use to install epoch. The first is to use [bower](http://bower.io/) from the command-line, like so:

```
bower install epoch
```

The second is to visit the [project site](http://fastly.github.io/epoch), download the latest release, and manually install it in your project. Both methods will provide you with the `epoch.X.Y.Z.min.js` and `epoch.X.Y.Z.min.css` files, simply include them along with jQuery and d3 in your page and you're ready to go.

### Requirements

Epoch has two external library requirements:

1. [d3](https://github.com/mbostock/d3) - Used to generate the basic charts.
2. [jQuery](https://github.com/jquery/jquery) - Used for DOM manipulation, etc.

### Developing Epoch

Developing Epoch is a reasonably straight forward process. In this section we'll cover the basic on how to develop Epoch by detailing common build task, exploring how the source is arranged, and finally show how to use rendering tests to aid development.

#### Configuring Development Environment

Epoch uses several tools in its development:

- [CoffeeScript](http://coffeescript.org/) (required)
- [node-minify](https://github.com/srod/node-minify) (optional, needed for building a minified release)
- [codo](https://github.com/coffeedoc/codo) (optional, needed for generating documentation)

All of the above tools can be installed via [npm](https://www.npmjs.org/). Run `npm install` in the project directory to install the above requirements. The remainder of this section assumes you have properly installed the requirements and have configured your `PATH` to run `npm`-installed executables.

#### Basic Development Process

After cloning the repository, the best way to get started developing against Epoch is to follow the following steps:

1. Change to the source directory for the project
2. Run `cake build` to build the JavaScript and CSS from source
    1. Optionally run `cake documentation` to compile the API documentation into HTML
3. In a web browser open the `test/index.html` and browse the rendering tests
4. Make changes in the CoffeeScript Source and use `cake build` or `cake watch` so that your changes are compiled
5. Use the rendering tests to see if your changes had the desired result

Keeping the rendering tests up-to-date is important! When developing use the following guidelines:

* When adding new features make sure to add new rendering tests
* When changing existing functionality, ensure that the appropriate rendering tests still pass
* If you want to make a new type of chart, add a whole new test suite for that chart!

Keeping the tests current makes it easier for others to review your code and spot issues. Also, pull requests without appropriate testing will not be merged... period.


#### Build Tasks

Epoch uses cake for its builds. The file defines the following tasks:
```
cake build                # Builds javascript from the coffeescript source (also packages)
cake package              # Packages the js and libraries into a single file
cake compile              # Compiles the packaged source via the Google Closure Compiler
cake watch
cake documentation        # Compiles API documentation
cake sass                 # Compile sass source into css
cake release              # Releases a new version of the library
cake clean                # Removes build files completely

  -v, --version      Sets the version number for the release task
```

For the most part you'll only need to use the following tasks:

1. `cake build` / `cake watch` - These will compile the CoffeeScript into JavaScript and compile SCSS to CSS.
2. `cake --version X.Y.Z release` - This is used to create minified release versions of the library.


#### Source Structure

The directory structure for the Epoch project follows some basic guidelines, here's an overview of how it is structured:

```
coffee/                - Main source directory
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
  epoch.coffee         - Main source file, defines name spaces, etc.
  time.coffee          - Base Classes for Real-Time Charts
lib/                   - "Baked in" libraries
sass/                  - Scss source for the default epoch stylesheet
test/                  - Rendering tests
  basic/               - Basic chart rendering tests
  real-time/           - Real-time rendering tests
```

### Copyright / Legal

The MIT License (MIT)

Copyright (c) 2014 Fastly, Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
