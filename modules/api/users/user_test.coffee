"use strict"

db = require "../connection"
crypto = require "crypto"

{model:User} = require "./user"
{schema:Schema} = require "./user"

user = undefined

describe "User model methods", ->
    beforeEach ->
        user = new User
        user.salt = crypto.randomBytes(64).toString "base64"
        user.hash = crypto.createHmac "sha256", user.salt
            .update "test"
            .digest "hex"

    it "should be defined", ->
        expect(Schema.methods).toBeDefined()

    describe "makeSalt", ->
        it "should exist", ->
            expect(Schema.methods.makeSalt).toBeDefined()

        it "should call crypto.randomBytes", ->
            stringDummy =
                toString: ->
                    return ""

            spyOn(stringDummy, "toString").andReturn ""
            spyOn(crypto, "randomBytes").andReturn stringDummy

            user.makeSalt()

            expect(crypto.randomBytes).toHaveBeenCalledWith(64)
            expect(stringDummy.toString).toHaveBeenCalled()

        it "should return a 64byte random base64 string", ->
            validBase64 = ///
                ^
                (?:[A-Za-z0-9+/]{4})*
                (?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{4})
                $
            ///
            salt1 = Schema.methods.makeSalt()
            salt2 = Schema.methods.makeSalt()

            expect(validBase64.test(salt1)).toBeTruthy()
            expect(validBase64.test(salt2)).toBeTruthy()

            expect(salt1 isnt salt2).toBeTruthy()


    describe "encryptPassword", ->
        it "should exist", ->
            expect(Schema.methods.encryptPassword).toBeDefined()

        xit "should call createHmac, update and digest", ->
            digestSpy =
                digest: (type) ->

            updateSpy =
                update: (val)->

            spyOn(digestSpy, "digest").andReturn ""
            spyOn(updateSpy, "update").andReturn digestSpy
            spyOn(crypto, "createHmac").andReturn updateSpy

            user.encryptPassword "test"

            expect(crypto.createHmac).toHaveBeenCalledWith(
                "sha256"
                user.salt
            )
            expect(digestSpy.digest).toHaveBeenCalledWith "hex"
            expect(updateSpy.update).toHaveBeenCalledWith "test"

        it 'should return undefined when no password is given', ->
            expect(user.encryptPassword()).toEqual undefined

    describe "authenticate", ->
        it "should exist and must be a function", ->
            expect(user.authenticate).toBeDefined()
            expect(user.authenticate).toEqual jasmine.any Function
            expect(Schema.methods.authenticate).toBeDefined()
            expect(Schema.methods.authenticate).toEqual jasmine.any Function

        it "should make a call to encryptPassword with the plainText", ->
            spyOn(user, "encryptPassword").andCallThrough()

            user.authenticate "test123"
            expect(user.encryptPassword).toHaveBeenCalledWith "test123"

        it "should return false on wrong password", ->
            expect(user.authenticate("asdf")).toBeFalsy()

        it "should return true on correct password", ->
            expect(user.authenticate("test")).toBeTruthy()
