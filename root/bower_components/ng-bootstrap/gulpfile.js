var gulp = require('gulp');
var minifyHTML = require('gulp-minify-html');
var uglify = require('gulp-uglify');
var concat = require('gulp-concat');
var templateCache = require('gulp-angular-templatecache');


gulp.task('default', function () {
    gulp.src('templates/**/*.html')
        .pipe(minifyHTML({
            quotes: true
        }))
        .pipe(templateCache({
            module: "ng-bootstrap"
        }))
        .pipe(gulp.dest('tmp'));

    gulp.src([
        'src/**/*.js',
        'tmp/**/*.js'
    ])
        .pipe(concat('ng-bootstrap.min.js'))
        .pipe(uglify())
        .pipe(gulp.dest('.'));
});