module Subscriptions exposing (subscriptions)

import Message exposing (Msg(..))
import Ports exposing (token)
import Types exposing (Model)


subscriptions : Model -> Sub Msg
subscriptions model =
    token SetToken
