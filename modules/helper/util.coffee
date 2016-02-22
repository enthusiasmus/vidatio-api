module.exports =
    hasAllProperties: (object, propertyList) ->
        for property in propertyList
            return false unless object.hasOwnProperty property
        return true

    updateObject: (newProperties, propertyList, object) ->
        for property in propertyList
            if newProperties[property]?
                object[property] = newProperties[property]
