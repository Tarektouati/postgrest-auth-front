port module Ports exposing (login, token)

import Types exposing (Payload)


port login : String -> Cmd msg


port token : (Maybe Payload -> msg) -> Sub msg
