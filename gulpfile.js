"use strict";

const gulp = require("gulp");
const sass = require("gulp-sass");
const babel = require("gulp-babel");
const riot = require("gulp-riot");
const concat = require("gulp-concat");
const autoprefix = require("gulp-autoprefixer");

// For template compilation
const {spawn, execFileSync} = require("child_process");

const VENDOR_CSS_FILES = "assets/css/vendor/**/*.@(scss|css)";
const CSS_FILES = ["assets/css/**/*.@(scss|css)", "!" + VENDOR_CSS_FILES];
const VENDOR_JS_FILES = "assets/js/vendor/**/*.js"
const JS_FILES = ["assets/js/**/*.js", "!" + VENDOR_JS_FILES];
const RIOT_FILES = "assets/js/riot/**/*.tag";
const FONT_FILES = "assets/fonts/**/*";
const IMG_FILES = "assets/img/**/*";

/* CSS files
assets/css
ext: .scss or .css
*/
gulp.task("css", function() {
  return gulp.src("assets/css/style.scss")
    .pipe(sass().on("error", sass.logError))
    .pipe(autoprefix({
      browsers: [">= 5%", "last 2 versions"],
      cascade: false
    }))
    .pipe(gulp.dest("build/css"));
});

/* Vendor CSS files
assets/css/vendor
ext: .scss or .css
*/
gulp.task("vendor-css", function() {
  return gulp.src(VENDOR_CSS_FILES)
    .pipe(sass().on("error", sass.logError))
    .pipe(autoprefix({
      browsers: [">= 5%", "last 2 versions"],
      cascade: false
    }))
    .pipe(concat("vendor.css"))
    .pipe(gulp.dest("build/css"));
});

/* JS files
assets/js
ext: .js
*/
gulp.task("js", function() {
  return gulp.src(JS_FILES)
    .pipe(babel({ presets: ["env"] }))
    .pipe(gulp.dest("build/js"));
});

/* Vendor JS files (these are only copied, not run through babel)
assets/js
ext: .js
*/
gulp.task("vendor-js", function() {
  return gulp.src(VENDOR_JS_FILES)
    .pipe(concat("vendor.js"))
    .pipe(gulp.dest("build/js"));
});

/* Fonts
assets/img
*/
gulp.task("fonts", function() {
  return gulp.src(FONT_FILES)
    .pipe(gulp.dest("build/fonts"));
});

/* Images
assets/img
*/
gulp.task("img", function() {
  return gulp.src(IMG_FILES)
    .pipe(gulp.dest("build/img"));
});

/* Riot JS files
assets/js
ext: .tag
*/
gulp.task("riotjs", function() {
  return gulp.src(RIOT_FILES)
    .pipe(riot())
    .pipe(concat("tags.js"))
    .pipe(babel({ presets: ["es2015-riot"] }))
    .pipe(gulp.dest("build/js"));
});

gulp.task("templates", function() {
  execFileSync("hamplify", ["assets/templates", "build/templates"]);
});

gulp.task("watch", function() {
  gulp.watch("assets/css/**/*.@(scss|css)", ["css", "vendor-css"]);
  gulp.watch("assets/js/**/*.js", ["js", "vendor-js"]);
  gulp.watch(RIOT_FILES, ["riotjs"]);
  gulp.watch(IMG_FILES, ["img"]);

  spawn("hamplify", ["assets/templates", "build/templates", "--watch"]);
});

gulp.task("default", ["css", "vendor-css", "js", "vendor-js", "fonts", "img", "riotjs", "templates"]);