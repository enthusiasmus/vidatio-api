"use strict"

frisby = require "frisby"

config = require "../../config"

userRoute = "/" + config.apiVersion + "/users"
authRoute = "/" + config.apiVersion + "/auth"

{model:User} = require "../users/user"

testuser =
    name: "authAdmin"
    email: "auth@admin.com"
    password: "admin"

frisby.globalSetup
    request:
        body: undefined
        headers:
            "Accept": "application/json"
        inspectOnFailure: true
        json: true
        baseUri: config.url

User.findOneAndRemove {
    "name": testuser.name
}, (error, doc, result) ->

    console.log "Error"
    console.log error
    console.log "doc"
    console.log doc

    console.log "result"
    console.log result

    frisby.create "Expect a successful registration of a user"
        .post userRoute,
            email: "admin@admin.com"
            name: "admin"
            password: "adminadmin"
        .after (error, res, body) ->
            expect(false).toBeTruthy()

            user = body

            console.log user

            frisby.create "unsuccessfully authenticate user"
                .get authRoute
                .auth user.email, "admin2"
                .expectStatus 401
                .toss()

            frisby.create "successfully authenticate user"
                .get authRoute
                .auth user.email, testuser.password
                .expectStatus 200
                .expectJSON {
                    message: "successfully authenticated"
                }
                .toss()
