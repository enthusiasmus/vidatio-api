"use strict"

frisby = require "frisby"

config = require "../../config"
{model:User} = require "../users/user"

userRoute = "/" + config.apiVersion + "/users"
authRoute = "/" + config.apiVersion + "/auth"

frisby.globalSetup
    request:
        body: undefined
        headers:
            "Accept": "application/json"
        inspectOnFailure: true
        json: true
        baseUri: config.url


frisby.create "Expect a successful registration of a user"
    .post userRoute,
        email: "auth@admin.com"
        name: "authAdmin"
        password: "admin"
    .expectHeaderContains "Content-Type", "json"
    .expectStatus 200
    .after (error, res, body) ->
        user = body

        frisby.create "unsuccessfully authenticate user"
            .get authRoute
            .auth user.email, "admin2"
            .expectStatus 401
            .toss()

        frisby.create "successfully authenticate user"
            .get authRoute
            .auth user.email, "admin"
            .expectStatus 200
            .expectJSON {
                message: "successfully authenticated"
            }
            .toss()
