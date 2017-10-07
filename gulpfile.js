"use strict";

const gulp = require("gulp");
const sass = require("gulp-sass");
const babel = require("gulp-babel");
const riot = require("gulp-riot");
const concat = require("gulp-concat");

// For template compilation
const {spawn, execFileSync} = require("child_process");

const CSS_FILES = "./assets/css/**/*.scss";
const JS_FILES = "./assets/js/**/*.js";
const RIOT_FILES = "./assets/js/riot/**/*.tag";

/* SCSS files
assets/css
ext: .scss
*/
gulp.task("css", function() {
  return gulp.src("./assets/css/style.scss")
    .pipe(sass().on("error", sass.logError))
    .pipe(gulp.dest("./build/css"));
});

/* JS files
assets/js
ext: .js
*/
gulp.task("js", function() {
  return gulp.src(JS_FILES)
    .pipe(babel({ presets: ["env"] }))
    .pipe(gulp.dest("./build/js"));
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
    .pipe(gulp.dest("./build/js"));
});

gulp.task("templates", function() {
  execFileSync("hamplify", ["assets/templates", "build/templates"]);
});

gulp.task("watch", function() {
  gulp.watch(CSS_FILES, ["css"]);
  gulp.watch(JS_FILES, ["js"]);
  gulp.watch(RIOT_FILES, ["riotjs"]);

  spawn("hamplify", ["assets/templates", "build/templates", "--watch"]);
});

gulp.task("default", ["css", "js", "riotjs", "templates"]);