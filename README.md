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
 │    ├── config.coffee.example
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
[Node-Inspector](https://github.com/node-inspector/node-inspector) is the debugging tool of choice, by default `gulp dev` starts the app in debug mode and Node-Inspector.

## Docs
[APIDOC](http://apidocjs.com/) - see homepage for details, can be generated with `gulp docs`, target directory is `./docs`. Take a look at the **apidoc** part in the `package.json` file.

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
[Bunyan](https://github.com/trentm/node-bunyan) is a simple logger, use (Log.io)[https://github.com/NarrativeScience/Log.io] for real-time logging in your browser - works great.

## Linting
There's a [CoffeeScript Style Guide](https://github.com/polarmobile/coffeescript-style-guide), you can modify the `coffeelint.json` file for your needs (e.g. 4 spaces instead of 2).

## EditorConfig
The `.editorconfig` contains all relevant styles for your editor, your IDE/Editor should support it, otherwise install a plugin from [editorconfig.org](http://editorconfig.org/).

## Some thoughts
The application is designed in a highly modularized way. 

* The `modules` folder contains the main application, it should serve the API.
    * `config.coffee`/`config.coffee.example` &rArr; the `config.coffee` file isn't included in the repository
    * `index.coffee` &rArr; exports a function, which starts the server
    * `logger.coffee` &rArr; here's the place, where the loggers are defined. In this case the logger and some logger specific routes (e.g. to change the log level of a router) are exported. The loggers are defined here because this makes other sub-modules like the api independent of the used logger, just make sure that these logging functions are implemented:
        * fatal
        * error
        * warn
        * info
        * debug
        * trace
* The `_apidoc` folder is used to store apidoc files which doesn't fit anywhere else, like `footer.md`.
* The API is designed as middleware for express.js, this means that a simple `app.use require("./api")` is everything you have to do. 
    * Within the `api` folder there is a separate folder for each REST Ressource, e.g. `penguins` which contains following files:
        * `_apidoc.coffee` &rArr; apidoc specifications from older versions should be moved here (to enable comparison between api versions)
        * `index.coffee` &rArr; exports the routes for single and multiple Resource (penguin / penguins).
        * `index_apitest.coffee` &rArr; self-explanatory
        * `penguin.coffee` &rArr; Mongoose Schema, Model
