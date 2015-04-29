"use strict"

gulp       = require("gulp-help")(require("gulp"))
coffee     = require "gulp-coffee"
coffeelint = require "gulp-coffeelint"
concat     = require "gulp-concat"
nodemon    = require "gulp-nodemon"
inspector  = require "gulp-node-inspector"
watch      = require "gulp-watch"
apidoc     = require "gulp-apidoc"
cache      = require "gulp-cached"
plumber    = require "gulp-plumber"
shell      = require "gulp-shell"
del        = require "del"


gutil      = require "gulp-util"


FILES = [
    "./modules/**/*.coffee"
]

TESTFILES = [
    "./modules/**/*_test.coffee"
    "./modules/**/*_apitest.coffee"
]

DIRS =
    build: "./build"
    docs:  "./docs"

APP = "app.js"

NODEMONSTARTED = false


JASMINE_APITEST = "jasmine-node -m '_apitest.' --matchall --forceexit --color --nohelpers #{DIRS.build}"
JASMINE_UNITTEST = "jasmine-node -m '_test.' --matchall --forceexit --color --nohelpers #{DIRS.build}"


gulp.task "run",
    "Run the App",
    [
        "lint"
        "build"
    ],
    ->
        require "./app"


gulp.task "default",
    "Runs 'develop' and 'test'.",
    [
        "develop"
    ]


gulp.task "develop",
    "Runs 'build' and watches the source files, rebuilds and starts tests on
    change, starts the debugger.",
    [
        "build"
        "nodemon"
        "debug"
        "sleep"
        "test"
    ],
    ->
        gulp.watch [ FILES ], [ "build", "test:unit", "test:api" ]
            .on "change", (event) ->
                if event.type is "deleted"
                    delete cache.caches["coffee"][event.path]
            .on "error", ->
                console.error "an error happened while watching coffee files"

        gulp.watch [ TESTFILES ], [ "build", "test:unit", "test:api" ]
            .on "change", (event) ->
                if event.type is "deleted"
                    delete cache.caches["coffee"][event.path]
            .on "error", ->
                console.log "an error happened while watching test files"


gulp.task "test",
    "Perform unit and API tests.",
    [
        "build"
        "nodemon"
        "sleep"
        "test:unit"
        "test:api"
    ]


gulp.task "debug",
    "Starts the app and the debugger.",
    [
        "nodemon"
    ],
    ->
        gulp.src( [] )
            .pipe inspector()



gulp.task "lint",
    "Lints all CoffeeScript source files.",
    ->
        gulp.src "./modules/**/*.coffee"
            .pipe coffeelint()
            .pipe coffeelint.reporter()


gulp.task "build",
    "Lints and builds the project to '#{DIRS.build}'.",
    [ "lint" ],
    ->
        gulp.src FILES
            .pipe plumber()
            .pipe cache("coffee")
            .pipe coffee( bare: true ).on( "error", -> this.emit "end" )
            .pipe gulp.dest( DIRS.build )



gulp.task "nodemon",
    "Starts the app with Nodemon."
    [
        "build"
    ],
    ->
        return true if NODEMONSTARTED
        NODEMONSTARTED = true
        nodemon(
                script: APP
                nodeArgs: [ "--debug" ]
                watch:  [
                    DIRS.build
                ]
                env:
                    "NODE_ENV": "development"
            ).on "restart", ->
                console.log "app restarted"


gulp.task "dev",
    "Shorthand for 'develop'.",
    [
        "develop"
    ]


gulp.task "sleep",
    "Sleep Helper.",
    shell.task "sleep 2", ignoreErrors: true


gulp.task "test:api:standalone",
    "Perform API tests (standalone).",
    [
        "lint"
        "build"
        "run"
    ],
    shell.task [ "sleep 1", JASMINE_APITEST ], ignoreErrors: true


gulp.task "test:api",
    "Perform all API tests.",
    [
        "lint"
        "build"
        "nodemon"
        "sleep"
        "test:unit"
    ],
    shell.task JASMINE_APITEST, ignoreErrors: true



gulp.task "test:unit",
    "Perform all unit tests."
    [
        "lint"
        "build"
        "sleep"
    ],
    shell.task JASMINE_UNITTEST, ignoreErrors: true


gulp.task "docs",
    "Generate apidocjs"
    [ "clean:docs" ],
    (cb) ->
        apidoc.exec
            src: "./modules"
            dest: DIRS.docs
        cb()



gulp.task "clean",
    "Delete '#{DIRS.build}' folder.",
    (cb) ->
        del [DIRS.build], cb


gulp.task "clean:docs",
    "Delete '#{DIRS.docs}' folder.",
    (cb) ->
        del [DIRS.docs], cb


