"use strict"

frisby = require "frisby"

config = require "../../config"
{model:User} = require "./user"

userRoute = "/" + config.apiVersion + "/users"

testuser =
    name: "userAdmin"
    email: "user@admin.com"
    password: "admin"


frisby.globalSetup
    request:
        body: undefined
        headers:
            "Accept": "application/json"
        inspectOnFailure: true
        json: true
        baseUri: config.url

frisby.create "Expect 500 on registering user without email"
    .post userRoute,
        email: ""
        username: ""
        password: "admin"
    .expectHeaderContains "Content-Type", "json"
    .expectStatus 500
    .expectJSON {
        error:
            name: "ValidationError"
            errors: [
                {
                    email:
                        i18n: "API.ERROR.USER.REGISTER.EMAIL.REQUIRED"
                        value: ""
                },
                {
                    name:
                        i18n: "API.ERROR.USER.REGISTER.NAME.REQUIRED"
                        value: ""
                }
            ]
    }
    .toss()

frisby.create "Expect email validation error on registering user with wrong email"
    .post userRoute,
        email: "admin"
        username: "admin"
        password: "admin"
    .expectHeaderContains "Content-Type", "json"
    .expectStatus 500
    .expectJSON {
        error:
            name: "ValidationError"
            errors: [{
                email:
                    i18n: "API.ERROR.USER.REGISTER.EMAIL.NOTVALID"
                    value: "admin"
            }]
    }
    .after (error, res, body) ->
        expect(body.error.name).toBe("ValidationError")
        expect(body.error).toEqual(jasmine.any(Object))
        expect(body.error.errors).toEqual(jasmine.any(Array))
        expect(body.error.errors[0]).toEqual(jasmine.any(Object))
        expect(body.error.errors[0].email.i18n).toBe("API.ERROR.USER.REGISTER.EMAIL.NOTVALID")
        expect(body.error.errors[0].email.value).toBe("admin")
    .toss()

frisby.create "Expect email validation error on registering user without email"
    .post userRoute,
        email: ""
        name: "admin"
        password: "admin"
    .expectHeaderContains "Content-Type", "json"
    .expectStatus 500
    .expectJSON {
        error:
            name: "ValidationError"
            errors: [{
                email:
                    i18n: "API.ERROR.USER.REGISTER.EMAIL.REQUIRED"
                    value: ""
            }]
    }
    .after (error, res, body) ->
        expect(body.error.name).toBe("ValidationError")
        expect(body.error).toEqual(jasmine.any(Object))
        expect(body.error.errors).toEqual(jasmine.any(Array))
        expect(body.error.errors[0].email).toEqual(jasmine.any(Object))
        expect(body.error.errors[0].email.i18n).toBe("API.ERROR.USER.REGISTER.EMAIL.REQUIRED")
        expect(body.error.errors[0].email.value).not.toBeTruthy()
    .toss()

frisby.create "Expect username validation error on registering user with special character"
    .post userRoute,
        email: "admin@admin.com"
        name: "admin  "
        password: "admin"
    .expectHeaderContains "Content-Type", "json"
    .expectStatus 500
    .expectJSON {
        error:
            name: "ValidationError"
            errors: [{
                name:
                    i18n: "API.ERROR.USER.REGISTER.NAME.NOTVALID"
                    value: "admin  "
            }]
    }
    .after (error, res, body) ->
        expect(body.error.name).toBe("ValidationError")
        expect(body.error).toEqual(jasmine.any(Object))
        expect(body.error.errors).toEqual(jasmine.any(Array))
        expect(body.error.errors[0].name).toEqual(jasmine.any(Object))
        expect(body.error.errors[0].name.i18n).toBe("API.ERROR.USER.REGISTER.NAME.NOTVALID")
        expect(body.error.errors[0].name.value).toBeTruthy()
    .toss()

frisby.create "Expect username validation error on registering user without username"
    .post userRoute,
        email: "admin@admin.com"
        name: ""
        password: "admin"
    .expectHeaderContains "Content-Type", "json"
    .expectStatus 500
    .expectJSON {
        error:
            name: "ValidationError"
            errors: [{
                name:
                    i18n: "API.ERROR.USER.REGISTER.NAME.REQUIRED"
                    value: ""
            }]
    }
    .after (error, res, body) ->
        expect(body.error.name).toBe("ValidationError")
        expect(body.error).toEqual(jasmine.any(Object))
        expect(body.error.errors).toEqual(jasmine.any(Array))
        expect(body.error.errors[0].name).toEqual(jasmine.any(Object))
        expect(body.error.errors[0].name.i18n).toBe("API.ERROR.USER.REGISTER.NAME.REQUIRED")
        expect(body.error.errors[0].name.value).not.toBeTruthy()
    .toss()

frisby.create "username shouldn't exist in database"
    .get userRoute + "/check?name=userAdmin"
    .expectHeaderContains "Content-Type", "json"
    .expectStatus 200
    .after (error, res, body) ->
        expect(body.message).toBeDefined()
        expect(body.message).toEqual("user not found")
        expect(body.available).toBeDefined()
        expect(body.available).toBeTruthy()
    .toss()

User.findOneAndRemove {
    name: testuser.name
}, (error, doc, result) ->

    frisby.create "Expect a successful registration of a user"
        .post userRoute,
            email: testuser.email
            name: testuser.name
            password: testuser.password
        .expectHeaderContains "Content-Type", "json"
        .expectStatus 200
        .after (error, res, body) ->
            user = body

            expect(user.email).toEqual(testuser.email)
            expect(user.name).toEqual(testuser.name)
            expect(user.deleted).not.toBeTruthy()

            frisby.create "username should already exist in database"
                .get userRoute + "/check?name=#{user.name}"
                .expectHeaderContains "Content-Type", "json"
                .expectStatus 200
                .expectJSON {
                    message: "#{testuser.name} not available"
                }
                .toss()

            frisby.create "email should already exist in database"
                .get userRoute + "/check?email=#{user.email}"
                .expectHeaderContains "Content-Type", "json"
                .expectStatus 200
                .expectJSON {
                    message: "#{testuser.email} not available"
                }
                .toss()

            frisby.create "Expect a mongo error because of duplicate entry"
                .post userRoute,
                    email: testuser.email
                    name: testuser.name
                    password: testuser.password
                .expectStatus 500
                .expectJSON {
                    error:
                        name: "MongoError"
                        errors: [{
                            mongo:
                                i18n: "API.ERROR.MONGO"
                                value: "undefined"
                        }]
                }
                .toss()
        .toss()
