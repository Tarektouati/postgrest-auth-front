module Encoder exposing (newUserEncoder, socialUserEncoder)

import Json.Encode as E
import UI.Form exposing (User)


newUserEncoder : User -> E.Value
newUserEncoder user =
    E.object
        [ ( "email", E.string user.email )
        , ( "password", E.string user.password )
        ]


socialUserEncoder : String -> String -> E.Value
socialUserEncoder state token =
    E.object
        [ ( "token", E.string token )
        , ( "state", E.string state )
        ]
