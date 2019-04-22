port module Ports exposing (Payload, login, token)

import Json.Encode as E


port login : String -> Cmd msg


type alias Payload =
    { token : String
    , provider : Maybe String
    }


port token : (Maybe Payload -> msg) -> Sub msg
