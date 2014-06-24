## Epoch - The Fastly Charting Library
By Ryan Sandor Richards

### Introduction

Epoch is a general purpose charting library for application developers and visualization designers. It focuses on two different aspects of visualization programming: **basic charts** for creating historical reports, and **real-time charts** for displaying frequently updating timeseries data.

### Getting Started

To get started using Epoch, please refer to the [Epoch Project Site](http://fastly.github.io/epoch). There you can find full documentation and guides to help you start using Epoch right away.

### Requirements

Epoch has two external library requirements:

1. [d3](https://github.com/mbostock/d3) - Used to generate the basic charts.
2. [jQuery](https://github.com/jquery/jquery) - Used for DOM manipulation, etc.

### Developing Epoch

Developing Epoch is a reasonably straight forward process. In this section we'll cover the basic on how to develop Epoch by detailing common build task, exploring how the source is arranged, and finally show how to use rendering tests to aid development.

#### Build Tasks

Epoch uses cake for its builds. The file defines the following tasks:
```
cake build                # Builds javascript from the coffeescript source (also packages).
cake package              # Packages the js and libraries into a single file.
cake compile              # Compiles the packaged source via the Google Closure Compiler
cake watch
cake sass                 # Compile sass source into css
cake release              # Releases a new version of the library

  -v, --version      Sets the version number for release
```

For the most part you'll only need to use the following tasks:

1. `cake build` / `cake watch` - These will compile the CoffeeScript into JavaScript and compile SCSS to css.
2. `cake --version X.Y.Z release` - This is used to create minified release versions of the library.


#### Source Structure

The directory structure for the Epoch project follows some basic guidelines, here's an overview of how it is structured:

```
coffee/                - Main source directory
  adapters/            - 3rd Party Library Adapters (currently only jQuery)
  basic/               - Basic Chart Classes
  time/                - Real-time Chart Classes
  adapters.coffee      - Options / Global Classes for Adapter Implementations
  basic.coffee         - Base Classes for Basic Charts
  epoch.coffee         - Main source file, defines name spaces, etc.
  time.coffee          - Base Classes for Real-Time Charts
doc/                   - Codo generated documentation
lib/                   - "Baked in" libraries
sass/                  - Scss source for the default epoch stylesheet
test/                  - Rendering tests
  basic/               - Basic chart rendering tests
  real-time/           - Real-time rendering tests
```


