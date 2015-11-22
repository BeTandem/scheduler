var gulp       = require('gulp'),
	  coffeelint = require('gulp-coffeelint'),
		nodemon    = require('gulp-nodemon'),
		coffee     = require('gulp-coffee'),
		clean      = require('gulp-clean'),
		watch      = require('gulp-watch'),
		livereload = require('gulp-livereload'),
		gutil      = require('gulp-util'),
		stylish    = require('coffeelint-stylish');

gulp.task('start', function () {
  nodemon({
    script: './dist/index.js'
  , ext: 'js coffee'
  , env: { 'NODE_ENV': 'development' }
  })
});

gulp.task('lint', function () {
    gulp.src('./server/**/*.coffee')
        .pipe(coffeelint())
        .pipe(coffeelint.reporter(stylish))
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

gulp.task('livereload', function(){
	livereload.reload();
});

gulp.task('watch', function(){
	livereload.listen();
	gulp.watch('./server/**/*.coffee', ['livereload', 'coffee', 'lint'])
});



gulp.task('default', ['coffee','start','lint','watch']);
gulp.task('clean', ['clean']);