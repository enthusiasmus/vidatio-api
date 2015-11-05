"use strict"

frisby = require "frisby"

config = require "../../config"
{model:User} = require "./user"

frisby.globalSetup
    request:
        body: undefined
        headers:
            "Accept": "application/json"
        inspectOnFailure: true
        json: true
        baseUri: config.url

frisby.create "Expect 500 on registering user without email"
    .post "/v0/user",
        email: ""
        username: ""
        password: "admin"
    .expectHeaderContains("Content-Type", "json")
    .expectStatus(500)
    .expectJSON
        error:
            name: "ValidationError"
            errors:
                email:
                    i18n: "API.USER.REGISTER.EMAIL.REQUIRED"
                    value: ""
                name:
                    i18n: "API.USER.REGISTER.NAME.REQUIRED"
                    value: ""
    .toss()

frisby.create "Expect email validation error on registering user with wrong email"
    .post "/v0/user",
        email: "admin"
        username: "admin"
        password: "admin"
    .expectHeaderContains("Content-Type", "json")
    .expectStatus(500)
    .expectJSON
        error:
            name: "ValidationError"
            errors:
                email:
                    i18n: "API.USER.REGISTER.EMAIL.NOTVALID"
                    value: "admin"
    .after (error, res, body) ->
        expect(body.error.name).toBe("ValidationError")
        expect(body.error.errors).toEqual(jasmine.any(Object))
        expect(body.error.errors.email).toEqual(jasmine.any(Object))
        expect(body.error.errors.email.i18n).toBe("API.USER.REGISTER.EMAIL.NOTVALID")
        expect(body.error.errors.email.value).toBe("admin")
    .toss()

frisby.create "Expect email validation error on registering user without email"
    .post "/v0/user",
        email: ""
        name: "admin"
        password: "admin"
    .expectHeaderContains("Content-Type", "json")
    .expectStatus(500)
    .expectJSON
        error:
            name: "ValidationError"
            errors:
                email:
                    i18n: "API.USER.REGISTER.EMAIL.REQUIRED"
                    value: ""
    .after (error, res, body) ->
        expect(body.error.name).toBe("ValidationError")
        expect(body.error.errors).toEqual(jasmine.any(Object))
        expect(body.error.errors.email).toEqual(jasmine.any(Object))
        expect(body.error.errors.email.i18n).toBe("API.USER.REGISTER.EMAIL.REQUIRED")
        expect(body.error.errors.email.value).not.toBeTruthy()
    .toss()

frisby.create "Expect username validation error on registering user with wrong username"
    .post "/v0/user",
        email: "admin@admin.com"
        name: "admin§"
        password: "admin"
    .expectHeaderContains("Content-Type", "json")
    .expectStatus(500)
    .expectJSON
        error:
            name: "ValidationError"
            errors:
                name:
                    i18n: "API.USER.REGISTER.NAME.NOTVALID"
                    value: "admin§"
    .after (error, res, body) ->
        expect(body.error.name).toBe("ValidationError")
        expect(body.error.errors).toEqual(jasmine.any(Object))
        expect(body.error.errors.name).toEqual(jasmine.any(Object))
        expect(body.error.errors.name.i18n).toBe("API.USER.REGISTER.NAME.NOTVALID")
        expect(body.error.errors.name.value).toBe("admin§")
    .toss()

frisby.create "Expect username validation error on registering user without username"
    .post "/v0/user",
        email: "admin@admin.com"
        name: ""
        password: "admin"
    .expectHeaderContains("Content-Type", "json")
    .expectStatus(500)
    .expectJSON
        error:
            name: "ValidationError"
            errors:
                name:
                    i18n: "API.USER.REGISTER.NAME.REQUIRED"
                    value: ""
    .after (error, res, body) ->
        expect(body.error.name).toBe("ValidationError")
        expect(body.error.errors).toEqual(jasmine.any(Object))
        expect(body.error.errors.name).toEqual(jasmine.any(Object))
        expect(body.error.errors.name.i18n).toBe("API.USER.REGISTER.NAME.REQUIRED")
        expect(body.error.errors.name.value).not.toBeTruthy()
    .toss()

User.remove {}, ->
    frisby.create "Expect a successful registration of a user"
        .post "/v0/user",
            email: "admin@admin.com"
            name: "admin"
            password: "admin"
        .expectHeaderContains("Content-Type", "json")
        .expectStatus(200)
        .after (error, res, body) ->
            user = body

            expect(user.email).toEqual("admin@admin.com")
            expect(user.name).toEqual("admin")
            expect(user.deleted).not.toBeTruthy()

            frisby.create "username should already exist in database"
                .get "/v0/user/check?name=#{user.name}"
                .expectHeaderContains("Content-Type", "json")
                .expectStatus(200)
                .expectJSON {
                    message: "admin not available"
                }
                .toss()

            frisby.create "user should not get successfully deleted because wrong authentication"
                .delete "/v0/user/#{user._id}"
                .auth user.email, "admin2"
                .expectStatus(401)
                .toss()

            frisby.create "Expect a mongo error because of duplicate entry"
                .post "/v0/user",
                    email: "admin@admin.com"
                    name: "admin"
                    password: "admin"
                .expectStatus(500)
                .expectJSON
                    error:
                        name: "MongoError"
                        errors:
                            mongo:
                                i18n: "API.MONGO.ERROR"
                                value: "undefined"
                .toss()

            frisby.create "user should get successfully deleted"
                .delete "/v0/user/#{user._id}"
                .auth user.email, "admin"
                .expectHeaderContains("Content-Type", "json")
                .expectStatus(200)
                .expectJSON {
                    message: "successfully deleted user"
                }
                .toss()

        .toss()
