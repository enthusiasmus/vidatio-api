"use strict"

{Router} = require "express"
passport = require "passport"

config   = require "../../config"
{penguins:logger}   = require "../../logger"


{model:Penguin} = require "./penguin"


penguin = Router()
penguins = Router()

basicAuth = passport.authenticate "basic",  session: false

adminAuth = (req, res, next) ->
    return res.status(401).end() unless req.user? and req.user.isAdmin?
    return res.status(401).end() if req.user.isAdmin is false
    logger.info { user: req.user }, "is admin"
    next()

penguinRoot = penguin.route "/"

###
@api {post} penguin/ POST - add a Penguin
@apiName addPenguin
@apiGroup Penguin
@apiVersion 0.0.1
@apiPermission admin
@apiDescription Add a Penguin.

@apiParam {String} name  Penguin Name.

@apiUse basicAuth
@apiUse SuccessPenguin
###
penguinRoot.post basicAuth, adminAuth, ( req, res ) ->
    penguin = new Penguin
    penguin.name = req.body.name

    logger.debug penguin: penguin, "try to add new Penguin"

    penguin.save ( err ) ->
        if err
            logger.error
                penguin: penguin
                error: err
            , "wasn't able to add Penguin"

            res.status( 500 ).json error: err
        else
            logger.info penguin: penguin, "sucessfully added new Penguin"
            res.json
                _id: penguin._id
                name: penguin.name




penguinIdRoot = penguin.route "/:id"

###
@api {get} penguin/:id/ GET - get a Penguin by Id
@apiName getPenguin
@apiGroup Penguin
@apiVersion 0.0.1
@apiPermission user
@apiDescription Get a Penguin by Id.

@apiUse basicAuth
@apiUse SuccessPenguin
###
penguinIdRoot.get basicAuth, ( req, res ) ->
    logger.debug id: req.params.id, "get a penguin by id"

    Penguin.findById req.params.id, "id name", ( error, penguin ) ->
        if error
            logger.error error: error, "wasn't able to get penguin"

            res.status( 500 ).json error: error
        else
            if not penguin? or penguin.deleted
                return res.status( 404 ).json error: "not found"

            delete penguin.deleted
            logger.debug penguin: penguin, "return penguin"
            res.json penguin


###
@api {delete} penguin/:id/ GET - delete a Penguin by Id
@apiName deletePenguin
@apiGroup Penguin
@apiVersion 0.0.1
@apiPermission admin
@apiDescription Delete a Penguin by Id. This doesn't really deletes the Penguin,
a deleted flag is set to True and the name of the Penguin is changed (to prevent
conflicts when creating a Penguin with the same name later).

@apiUse basicAuth
@apiUse SuccessPenguin
###
penguinIdRoot.delete basicAuth, ( req, res ) ->
    logger.debug id: req.params.id, "delete a penguin by id"

    Penguin.findById req.params.id, "id name", ( error, penguin ) ->
        if error
            logger.error error: error, "wasn't able to get penguin"

            res.status( 500 ).json error: error
        else
            if not penguin? or penguin.deleted
                return res.status( 404 ).json error: "not found"

            penguin.deleted = true
            penguin.name = "#{ penguin._id }:#{ penguin.name }"
            penguin.save ( error ) ->
                if error
                    logger.error error: error, "wasn't able to save penguin"

                    res.status( 500 ).json error: error
                else
                    logger.debug penguin: penguin, "return penguin"
                    res.json msg: "successfully deleted penguin"


penguinsRoot = penguins.route "/"

###
@api {get} penguins/ GET - get all Penguins
@apiName getPenguins
@apiGroup Penguins
@apiVersion 0.0.1
@apiPermission user
@apiDescription Get all available Penguins.

@apiUse basicAuth
@apiUse SuccessPenguins
###
penguinsRoot.get basicAuth, ( req, res ) ->
    logger.debug "get all penguins"

    Penguin.find deleted: false, "id name", ( error, penguins ) ->
        if error
            logger.error error: error, "wasn't able to get all penguins"

            res.status( 500 ).json error: error
        else
            unless penguins?
                penguins = []

            logger.debug penguins: penguins, "return penguin"
            res.json penguins

module.exports =
    penguin:   penguin
    penguins:  penguins
