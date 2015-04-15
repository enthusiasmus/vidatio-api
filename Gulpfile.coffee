"use strict"

gulp       = require("gulp-help")(require("gulp"))
coffee     = require "gulp-coffee"
coffeelint = require "gulp-coffeelint"
concat     = require "gulp-concat"
nodemon    = require "gulp-nodemon"
watch      = require "gulp-watch"
apidoc     = require "gulp-apidoc"
cache      = require "gulp-cached"
plumber    = require "gulp-plumber"
shell      = require "gulp-shell"
del        = require "del"

gutil = require "gulp-util"

FILES = [
    "./modules/**/*.coffee"
]
#    "!./modules/**/*_test.coffee"

TESTFILES = [
    "./modules/**/*_test.coffee"
    "./modules/**/*_apitest.coffee"
]

BUILD =
    base: "./build"
BUILD.docs = "#{BUILD.base}/docs"
BUILD.api  = "#{BUILD.base}/api"
BUILD.ws  = "#{BUILD.base}/ws"
BUILD.js = "#{BUILD.base}/*.js"

APP = "app.js"

MODULES = "./modules"

API = "#{MODULES}/api"

gulp.task "lint"
    , "Lints all CoffeeScript source files."
    , ->
        gulp.src "./modules/**/*.coffee"
            .pipe coffeelint()
            .pipe coffeelint.reporter()


gulp.task "build"
    , "Lints and builds the project to './.app/'."
    , [ "lint" ]
    , ->
        gulp.src FILES
            .pipe plumber()
            .pipe cache("coffee")
            .pipe coffee( bare: true ).on( "error", ->
                this.emit "end"
            )
            .pipe gulp.dest( BUILD.base )

gulp.task "default"
    , "Runs 'develop' and 'test'."
    , [ "develop" ]

gulp.task "develop"
    , "Runs 'build' and watches the source files, rebuilds on change"
    , [ "build", "nodemon", "sleep", "test" ]
    , ->
        gulp.watch [ FILES ], [ "build", "test:unit", "test:api" ]
            .on "change", (event) ->
                console.log "alksdgjoaigjaosgij"
                if event.type is "deleted"
                    delete cache.caches["coffee"][event.path]
            .on "error", ->
                console.log "error?"

        gulp.watch [ TESTFILES ], [ "build", "test:unit", "test:api" ]
            .on "change", (event) ->
                if event.type is "deleted"
                    delete cache.caches["coffee"][event.path]
            .on "error", ->
                console.log "error?"

nodemonStarted = false

gulp.task "nodemon", ["build"], ->
    return true if nodemonStarted
    nodemonStarted = true
    nodemon(
            script: APP
            watch:  [
                BUILD.base
            ]
            env:
                "NODE_ENV": "development"
        ).on "restart", ->
            console.log "app restarted"

gulp.task "dev"
    , "Shorthand for develop"
    , ["develop"]


gulp.task "test"
    , "Perform unit and API tests."
    , ["build", "nodemon", "sleep",  "test:unit", "test:api"]

gulp.task "sleep"
    , "Sleep Helper"
    , shell.task( "sleep 2", ignoreErrors: true )

gulp.task "test:api:standalone"
    , "Perform API tests. (standalone)"
    , ["lint", "build", "run"]
    , shell.task([
        "sleep 1",
        "jasmine-node " +
        "--coffee " +
        "-m '_apitest.' " +
        "--matchall " +
        "--forceexit " +
        "--color " +
        "--nohelpers " +
        "./modules "
        #"--verbose " +
    ], ignoreErrors: true)

gulp.task "run"
    , "Run the App"
    , ["lint", "build"]
    , ->
        require "./app"

gulp.task "test:api"
    , "Perform all API tests."
    , ["lint","build", "nodemon", "sleep", "test:unit" ] #"nodemon", "sleep",
    , shell.task(
        "jasmine-node " +
        "--coffee " +
        "-m '_apitest.' " +
        "--matchall " +
        "--forceexit " +
        "--color " +
        "--nohelpers " +
        "./modules "
        #"--verbose " +
    , ignoreErrors: true)

gulp.task "test:unit"
    , "Perform all unit tests."
    , ["lint", "build", "sleep"]
    , shell.task(
        "jasmine-node " +
        "--coffee " +
        "--matchall " +
        "--forceexit " +
        "--color " +
        "--nohelpers " +
        "-m '_test.' " +
        "./modules "
        #"--verbose " +
    , ignoreErrors: true)

gulp.task "clean"
    , "Delete './build/' folder."
    , (cb) ->
        del [BUILD.base], cb

gulp.task "clean:docs"
    , "Delete `docs` folder."
    , (cb) ->
        del [BUILD.docs], cb

gulp.task "docs"
    , "Generate apidocjs"
    , ["clean:docs"]
    , (cb) ->
        apidoc.exec(
            src: "./modules"
            dest: BUILD.docs
            #verbose: true
        )
        cb()

