"use strict"

fs = require "fs"

gulp       = require("gulp-help")(require("gulp"))
coffee     = require "gulp-coffee"
coffeelint = require "gulp-coffeelint"
concat     = require "gulp-concat"
nodemon    = require "gulp-nodemon"
inspector  = require "gulp-node-inspector"
watch      = require "gulp-watch"
apidoc     = require "apidoc"
cache      = require "gulp-cached"
plumber    = require "gulp-plumber"
shell      = require "gulp-shell"
watch      = require "gulp-watch"
del        = require "del"

jn = require "jasmine-node"
gutil      = require "gulp-util"

FILES = [
    "./modules/**/*.coffee"
]

TESTFILES = [
    "./modules/**/*_test.coffee"
    "./modules/**/*_apitest.coffee"
]

DIRS =
    modules: "./modules"
    build: "./build"
    docs:  "./docs"

APP = "./app.js"

NODEMONSTARTED = false
JASMINE_APITEST = "jasmine-node -m '_apitest.' --matchall --forceexit --color --nohelpers #{DIRS.build}"
JASMINE_UNITTEST = "jasmine-node -m '_test.' --matchall --forceexit --color --nohelpers #{DIRS.build}"

gulp.task "default",
    "Runs 'develop' and 'test'.",
    [
        "develop"
    ]

gulp.task "production",
    "Runs 'nodemon'",
    [
        "nodemon-production"
    ]

gulp.task "develop",
    "Runs 'build' and watches the source files, rebuilds and starts tests on
    change, starts the debugger.",
    [
        "build"
        "nodemon"
        "sleep"
        "test"
    ],->

        watch FILES, ( file ) ->
            if file.isNull()
                # delete build file on deletion
                buildFile = file.relative.replace /^modules/, "build"
                buildFile = buildFile.replace /coffee$/, "js"
                fs.unlinkSync __dirname + "/" + buildFile

                delete cache.caches.coffee[__dirname + "/" + file.relative]
            gulp.start "build"

        gulp.src( [] )
            .pipe inspector()

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
        gulp.src FILES
            .pipe coffeelint()
            .pipe coffeelint.reporter()

gulp.task "build",
    "Lints and builds the project to '#{DIRS.build}'.",
    [
        "lint"
        "docs"
    ],
    ->
        gulp.src FILES
            .pipe plumber()
            .pipe cache( "coffee" )
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

gulp.task "nodemon-production",
    "Starts the app with Nodemon in Production."
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
                    "NODE_ENV": "production"
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
    "Generate apidoc."
    [
        "clean:docs"
    ],
    (cb) ->
        apidoc.createDoc
            src: DIRS.modules
            dest: DIRS.docs
            includeFilters: [ ".*\\.coffee$" ]
            verbose: true
        cb()

gulp.task "clean",
    "Delete '#{DIRS.build}' folder.",
    (cb) ->
        del [DIRS.build], cb

gulp.task "clean:docs",
    "Delete '#{DIRS.docs}' folder.",
    (cb) ->
        del [DIRS.docs], cb
