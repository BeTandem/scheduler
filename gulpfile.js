var gulp       = require('gulp'),
	  coffeelint = require('gulp-coffeelint'),
	  // reporter   = require('coffeelint-stylish').reporter
		nodemon    = require('gulp-nodemon'),
		coffee     = require('gulp-coffee'),
		clean      = require('gulp-clean'),
		watch      = require('gulp-watch'),
		livereload = require('gulp-livereload'),
		gutil      = require('gulp-util');

gulp.task('start', function () {
  nodemon({
    script: './dist/index.js'
  , ext: 'js coffee'
  , env: { 'NODE_ENV': 'development' }
  })
});

gulp.task('lint', function () {
    gulp.src('./server/*.coffee')
        .pipe(coffeelint())
        .pipe(coffeelint.reporter())
});

gulp.task('coffee', function() {
  gulp.src('./server/**/*.coffee')
    .pipe(coffee({bare: true}).on('error', gutil.log))
    .pipe(gulp.dest('./dist'));
});

gulp.task('clean', function(){
	gulp.src('./dist/*')
	.pipe(clean({force:true}));
});

gulp.task('watch', function(){
	livereload.listen();
	gulp.watch('./server/**/*.coffee', ['livereload', 'coffee'])
});



gulp.task('default', ['coffee','start','lint','watch']);