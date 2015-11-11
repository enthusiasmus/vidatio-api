# "use strict"

# frisby = require "frisby"

# config = require "../../config"
# {model:User} = require "./user"

# userRoute = "/" + config.apiVersion + "/users"

# testuser =
#     name: "userAdmin"
#     email: "user@admin.com"
#     password: "admin"


# frisby.globalSetup
#     request:
#         body: undefined
#         headers:
#             "Accept": "application/json"
#         inspectOnFailure: true
#         json: true
#         baseUri: config.url

# frisby.create "Expect 500 on registering user without email"
#     .post userRoute,
#         email: ""
#         username: ""
#         password: "admin"
#     .expectHeaderContains "Content-Type", "json"
#     .expectStatus 500
#     .expectJSON {
#         error:
#             name: "ValidationError"
#             errors:
#                 email:
#                     i18n: "API.USER.REGISTER.EMAIL.REQUIRED"
#                     value: ""
#                 name:
#                     i18n: "API.USER.REGISTER.NAME.REQUIRED"
#                     value: ""
#     }
#     .toss()

# frisby.create "Expect email validation error on registering user with wrong email"
#     .post userRoute,
#         email: "admin"
#         username: "admin"
#         password: "admin"
#     .expectHeaderContains "Content-Type", "json"
#     .expectStatus 500
#     .expectJSON {
#         error:
#             name: "ValidationError"
#             errors:
#                 email:
#                     i18n: "API.USER.REGISTER.EMAIL.NOTVALID"
#                     value: "admin"
#     }
#     .after (error, res, body) ->
#         expect(body.error.name).toBe("ValidationError")
#         expect(body.error.errors).toEqual(jasmine.any(Object))
#         expect(body.error.errors.email).toEqual(jasmine.any(Object))
#         expect(body.error.errors.email.i18n).toBe("API.USER.REGISTER.EMAIL.NOTVALID")
#         expect(body.error.errors.email.value).toBe("admin")
#     .toss()

# frisby.create "Expect email validation error on registering user without email"
#     .post userRoute,
#         email: ""
#         name: "admin"
#         password: "admin"
#     .expectHeaderContains "Content-Type", "json"
#     .expectStatus 500
#     .expectJSON {
#         error:
#             name: "ValidationError"
#             errors:
#                 email:
#                     i18n: "API.USER.REGISTER.EMAIL.REQUIRED"
#                     value: ""
#     }
#     .after (error, res, body) ->
#         expect(body.error.name).toBe("ValidationError")
#         expect(body.error.errors).toEqual(jasmine.any(Object))
#         expect(body.error.errors.email).toEqual(jasmine.any(Object))
#         expect(body.error.errors.email.i18n).toBe("API.USER.REGISTER.EMAIL.REQUIRED")
#         expect(body.error.errors.email.value).not.toBeTruthy()
#     .toss()

# frisby.create "Expect username validation error on registering user with wrong username"
#     .post userRoute,
#         email: "admin@admin.com"
#         name: "admin§"
#         password: "admin"
#     .expectHeaderContains "Content-Type", "json"
#     .expectStatus 500
#     .expectJSON {
#         error:
#             name: "ValidationError"
#             errors:
#                 name:
#                     i18n: "API.USER.REGISTER.NAME.NOTVALID"
#                     value: "admin§"
#     }
#     .after (error, res, body) ->
#         expect(body.error.name).toBe("ValidationError")
#         expect(body.error.errors).toEqual(jasmine.any(Object))
#         expect(body.error.errors.name).toEqual(jasmine.any(Object))
#         expect(body.error.errors.name.i18n).toBe("API.USER.REGISTER.NAME.NOTVALID")
#         expect(body.error.errors.name.value).toBe("admin§")
#     .toss()

# frisby.create "Expect username validation error on registering user without username"
#     .post userRoute,
#         email: "admin@admin.com"
#         name: ""
#         password: "admin"
#     .expectHeaderContains "Content-Type", "json"
#     .expectStatus 500
#     .expectJSON {
#         error:
#             name: "ValidationError"
#             errors:
#                 name:
#                     i18n: "API.USER.REGISTER.NAME.REQUIRED"
#                     value: ""
#     }
#     .after (error, res, body) ->
#         expect(body.error.name).toBe("ValidationError")
#         expect(body.error.errors).toEqual(jasmine.any(Object))
#         expect(body.error.errors.name).toEqual(jasmine.any(Object))
#         expect(body.error.errors.name.i18n).toBe("API.USER.REGISTER.NAME.REQUIRED")
#         expect(body.error.errors.name.value).not.toBeTruthy()
#     .toss()


# frisby.create "username shouldnt exist in database"
#     .get userRoute + "/check?name=userAdmin"
#     .expectHeaderContains "Content-Type", "json"
#     .expectStatus 200
#     .after (error, res, body) ->
#         expect(body.message).toBeDefined()
#         expect(body.message).toEqual("user not found")
#         expect(body.available).toBeDefined()
#         expect(body.available).toBeTruthy()
#     .toss()

# frisby.create "username shouldnt exist in database"
#     .get userRoute + "/check?email=user@admin.com"
#     .expectHeaderContains "Content-Type", "json"
#     .expectStatus 200
#     .after (error, res, body) ->
#         expect(body.message).toBeDefined()
#         expect(body.message).toEqual("user not found")
#         expect(body.available).toBeDefined()
#         expect(body.available).toBeTruthy()
#     .toss()

# User.remove {
#     "name": testuser.name
# }, ->
#     frisby.create "Expect a successful registration of a user"
#         .post userRoute,
#             email: testuser.email
#             name: testuser.name
#             password: testuser.password
#         .expectHeaderContains "Content-Type", "json"
#         .expectStatus 200
#         .after (error, res, body) ->
#             user = body

#             expect(user.email).toEqual(testuser.email)
#             expect(user.name).toEqual(testuser.name)
#             expect(user.deleted).not.toBeTruthy()

#             frisby.create "username should already exist in database"
#                 .get userRoute + "/check?name=#{user.name}"
#                 .expectHeaderContains "Content-Type", "json"
#                 .expectStatus 200
#                 .expectJSON {
#                     message: "#{testuser.name} not available"
#                 }
#                 .toss()

#             frisby.create "email should already exist in database"
#                 .get userRoute + "/check?email=#{user.email}"
#                 .expectHeaderContains "Content-Type", "json"
#                 .expectStatus 200
#                 .expectJSON {
#                     message: "#{testuser.email} not available"
#                 }
#                 .toss()

#             frisby.create "user should not get successfully deleted because wrong authentication"
#                 .delete userRoute + "/#{user._id}"
#                 .auth user.email, "admin2"
#                 .expectStatus 401
#                 .toss()

#             frisby.create "Expect a mongo error because of duplicate entry"
#                 .post userRoute,
#                     email: testuser.email
#                     name: testuser.name
#                     password: testuser.password
#                 .expectStatus 500
#                 .expectJSON {
#                     error:
#                         name: "MongoError"
#                         errors:
#                             mongo:
#                                 i18n: "API.MONGO.ERROR"
#                                 value: "undefined"
#                 }
#                 .toss()

#             frisby.create "user should get successfully deleted"
#                 .delete userRoute + "/#{user._id}"
#                 .auth user.email, testuser.password
#                 .expectHeaderContains "Content-Type", "json"
#                 .expectStatus 200
#                 .expectJSON {
#                     message: "successfully deleted user"
#                 }
#                 .toss()

#             frisby.create "username should be valid again"
#                 .get userRoute + "/check?name=#{user.name}"
#                 .expectHeaderContains "Content-Type", "json"
#                 .expectStatus 200
#                 .expectJSON {
#                     message:  "user not found"
#                     available: true
#                 }
#                 .toss()

#             frisby.create "email should be valid again"
#                 .get userRoute + "/check?email=#{user.email}"
#                 .expectHeaderContains "Content-Type", "json"
#                 .expectStatus 200
#                 .expectJSON {
#                     message:  "user not found"
#                     available: true
#                 }
#                 .toss()

#         .toss()
