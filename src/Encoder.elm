module Encoder exposing (newUserEncoder, socialUserEncoder)

import Json.Encode as E


newUserEncoder : String -> String -> E.Value
newUserEncoder email password =
    E.object
        [ ( "email", E.string email )
        , ( "password", E.string password )
        ]


socialUserEncoder : String -> String -> E.Value
socialUserEncoder state token =
    E.object
        [ ( "token", E.string token )
        , ( "state", E.string state )
        ]
