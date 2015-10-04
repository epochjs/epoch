'use strict';

require('coffee-script/register'); // For coffee-script mocha unit tests

var gulp = require('gulp');
var coffee = require('gulp-coffee');
var concat = require('gulp-concat');
var mocha = require('gulp-mocha');
var order = require('gulp-order');
var rename = require('gulp-rename');
var sass = require('gulp-sass');
var uglify = require('gulp-uglify');
var gutil = require('gulp-util');
var del = require('del');
var exec = require('child_process').exec;

/**
 * Common directories used by tasks below.
 * @type {object}
 */
var path = {
  source: {
    coffee: 'src/',
    sass: 'sass/'
  },
  dist: {
    js: 'dist/js/',
    css: 'dist/css/'
  },
  test: {
    unit: 'tests/unit/'
  },
  doc: 'doc/'
};

/**
 * The default task simply calls the master 'build' task.
 */
gulp.task('default', ['build']);

/**
 * Builds the distribution files by packaging the compiled javascript source
 * into the `dist/js/` directory and building the css into the `dist/css`
 * directory
 */
gulp.task('build', ['sass', 'sass-minify'], function () {
  gulp.src(path.source.coffee + '**/*.coffee')
    .pipe(coffee({bare: true}).on('error', gutil.log))
    .pipe(order([
      'epoch.js',
      'core/context.js',
      'core/util.js',
      'core/d3.js',
      'core/format.js',
      'core/chart.js',
      'core/css.js',
      'data.js',
      'model.js',
      'basic.js',
      'basic/*.js',
      'time.js',
      'time/*.js',
      'adapters.js',
      'adapters/*.js'
    ]))
    .pipe(concat('epoch.js'))
    .pipe(gulp.dest(path.dist.js))
    .pipe(uglify().on('error', gutil.log))
    .pipe(rename('epoch.min.js'))
    .pipe(gulp.dest(path.dist.js));
});

/**
 * Generates epoch CSS from Sass source.
 */
gulp.task('sass', function () {
  gulp.src(path.source.sass + 'epoch.scss')
    .pipe(sass({ outputStyle: 'compact' }))
    .pipe(rename('epoch.css'))
    .pipe(gulp.dest(path.dist.css));
});

/**
 * Generates the minified version of the epoch css from sass source.
 */
gulp.task('sass-minify', function () {
  gulp.src(path.source.sass + 'epoch.scss')
    .pipe(sass({ outputStyle: 'compressed' }))
    .pipe(rename('epoch.min.css'))
    .pipe(gulp.dest(path.dist.css));
});

/**
 * Watch script for recompiling JavaScript and CSS
 */
gulp.task('watch', function () {
  gulp.watch(path.source.coffee + '**/*.coffee', ['build']);
  gulp.watch(path.source.sass + '**/*.scss', ['sass', 'sass-minify']);
});

/**
 * Runs mocha unit tests for the project. This can also be initiated by calling
 * `npm test` (which simply calls into this gulp task).
 */
gulp.task('unit', ['build'], function () {
  gulp.src(path.test.unit + '**/*.coffee')
    .pipe(mocha({ reporter: 'dot' }));
});

/**
 * Cleans all build and distribution files.
 */
gulp.task('clean', function (cb) {
  del([ path.dist.js, path.dist.css]).then(function () {
    cb();
  });
});

/**
 * Generates codo documentation from the project's coffeescript source.
 */
gulp.task('doc', function (cb) {
  var command = [
    './node_modules/.bin/codo --quiet --private',
    '--name Epoch --readme README.md --title "Epoch Documentation"',
    '--output #{dirs.doc} #{dirs.src} - LICENSE'
  ].join('');
  exec(command, cb);
});
