'use strict';

/**
  * Load Dependiencies
  */

var gulp       = require('gulp'),
    coffeelint = require('gulp-coffeelint'),
    nodemon    = require('gulp-nodemon'),
    coffee     = require('gulp-coffee'),
    clean      = require('gulp-clean'),
    watch      = require('gulp-watch'),
    gutil      = require('gulp-util'),
    uglify     = require('gulp-uglify'),
    stylish    = require('coffeelint-stylish'),
    mocha      = require('gulp-mocha'),
    sourcemaps = require('gulp-sourcemaps'),
    apidoc     = require('gulp-apidoc');


/**
  * Gulp Configurations
  */

var config = {
  prod: !!gutil.env.production,
  build: !!gutil.env.build,
  init: function(){
    this.env = this.prod ? 'production' : 'development';
    return this;
  }
}.init();


/**
  * Build Tasks
  */

// Lint Coffee files
gulp.task('lint', function () {
  gulp.src('./server/**/*.coffee')
    .pipe(coffeelint())
    .pipe(coffeelint.reporter(stylish))
});

// Compile coffee files to js
gulp.task('coffee', function() {

  // Production Uglify (minify & compress)
  if(config.prod){
    gulp.src('./server/**/*.coffee')
      .pipe(coffee({bare: true}).on('error', gutil.log))
      .pipe(uglify())
      .pipe(gulp.dest('./dist'));
  }

  // Development Build
  else{
    gulp.src('./server/**/*.coffee')
      .pipe(coffee({bare: true}).on('error', gutil.log))
      .pipe(gulp.dest('./dist'));
  }

});

// Clean distribution folder
gulp.task('clean', function(){
	gulp.src('./dist/*')
	.pipe(clean({force:true}));
});

// Watch for changes in js
gulp.task('watch', function(){
  if(!config.build) {
    gulp.watch('./server/**/*.coffee', ['coffee', 'lint']);
  }
});

/**
 * APIDOC
 */

gulp.task('apidoc', function(done){
  apidoc({
    src: "apidocs/docs/",
    dest: "apidocs/build",
    debug: true,
    template: "apidocs/template"
  },done);
});


/**
  * Testing Tasks
  */

gulp.task('test', function(){
  process.env.NODE_ENV = 'test';
  process.env.PORT = 3002;
  require('coffee-script/register'); // Required for mocha
  var reporter = !!process.env.CIRCLECI ? 'mocha-junit-reporter' : 'spec';
  gulp.src('tests/**/*.coffee', {read:false})
  .pipe(mocha({
    reporter: reporter,
    reporterOptions: {
      mochaFile: process.env.CIRCLE_TEST_REPORTS + '/junit-report.xml'
    },
    compilers: 'coffee'
  }))
  .once('end', function () {
    process.exit();
  });
});


/**
  * Serve Tasks
  */

// Start Nodemon Server
gulp.task('nodemon', function () {
  if (!config.build) {
    nodemon({
      exec: 'node --debug',
      script: './dist/index.js',
      ext: 'coffee',
      env: {'NODE_ENV': config.env}
    });
  }
});

// default task
gulp.task('default', ['coffee', 'lint', 'nodemon', 'watch']);
