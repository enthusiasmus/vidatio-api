###
@apiDefine basicAuth
@apiHeader {string} Authorization  Basic Auth Credentials, see (<a href="http://de.wikipedia.org/wiki/HTTP-Authentifizierung#Basic_Authentication">Basic Auth</a>).
@apiHeaderExample {json} Auth-Header-Example:
    {
        "Authorization": "Basic d2lraTpwZWRpYQ=="
    }
###

###
@apiDefine auth
@apiHeader {string} user        User's e-mail or User's name.
@apiHeader {string} password    User's password.
###
