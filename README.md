# Vidatio - API

## Folder Structure

```sh
api
 ├── .editorconfig
 ├── .gitignore
 ├── .git
 │     ├──*
 │     *
 ├── app.coffee
 ├── app.js
 ├── coffeelint.json
 ├── Gulpfile.coffee
 ├── Gulpfile.js
 ├── package.json
 ├── README.md
 ├── logs
 │    ├── access.log
 │    ├── api.log
 │    └── penguins.log
 ├── modules
 │    ├── _apidoc                           
 │    │    ├── auth.coffee
 │    │    ├── footer.md
 │    │    ├── header.md
 │    │    └── permissions.coffee
 │    ├── api
 │    │    ├── connection.coffee
 │    │    ├── index_apitest.coffee
 │    │    ├── index.coffee
 │    │    └── penguins
 │    │         ├── _apidoc.coffee
 │    │         ├── index_apitest.coffee
 │    │         ├── index.coffee
 │    │         └── penguin.coffee
 │    ├── config.coffee
 │    ├── index_apitest.coffee
 │    ├── index.coffee
 │    ├── index_test.coffee
 │    └── logger.coffee
 ├── build
 │    ├──*
 │    *
 └── docs
      ├──*
      *
 
```

## Unit Tests
All test files are in the same folder where the FUT (file under test) is, if you want to test the file `appleJuiceMaker.js`, the corresponding test file have to be `appleJuiceMaker_test.js`.

In this setup, [Jasmine](http://jasmine.github.io/) is used for testing.

## Api tests
[Frisby.js](frisbyjs.com) is used for Api Tests, same naming conventions apply for Api Tests like for Unit Tests except that they end with `_apitest.js`. 

## Debug
[Node-Inspector](https://github.com/node-inspector/node-inspector) is the debugging tool of choice.

## Docs
[APIDOC](http://apidocjs.com/) - see homepage for details.

## Gulp
Self-explanatory. Here's the output from `gulp help`:

```sh
Usage
  gulp [task]

Available tasks
  build                Lints and builds the project to './build'.
  clean                Delete './build' folder.
  clean:docs           Delete './docs' folder.
  debug                Starts the app and the debugger.
  default              Runs 'develop' and 'test'.
  dev                  Shorthand for 'develop'.
  develop              Runs 'build' and watches the source files, rebuilds and starts tests on change, starts the debugger.
  docs                 Generate apidoc.
  help                 Display this help text.
  lint                 Lints all CoffeeScript source files.
  nodemon              Starts the app with Nodemon.
  run                  Run the App.
  sleep                Sleep Helper.
  test                 Perform unit and API tests.
  test:api             Perform all API tests.
  test:api:standalone  Perform API tests (standalone).
  test:unit            Perform all unit tests.
```

## Logging
