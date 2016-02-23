"use strict"

db = require "../connection"
mongoose = require "mongoose"

{model:Tag} = require "./tag"
{schema:Schema} = require "./tag"

describe "Tag model statics", ->
    it "should be defined", ->
        expect(Schema.statics).toBeDefined()

    describe "findOrCreate", ->
        it "should exist", ->
            expect(Schema.statics.findOrCreate).toBeDefined()
