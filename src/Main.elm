module Main exposing (init, main)

import Browser exposing (element)
import Message exposing (Msg(..))
import Subscriptions exposing (subscriptions)
import Types exposing (Flags, Model)
import UI.Form exposing (initUser)
import Update exposing (update)
import View exposing (view)


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { modal = False
      , email = ""
      , password = ""
      , rePassword = ""
      , endpoint = flags.api
      , state = flags.state
      , accessToken = ""
      , formUser = initUser
      , user = { id = "", success = False }
      , socialUser = { id = "", email = "" }
      , error = Nothing
      }
    , Cmd.none
    )


main : Program Flags Model Msg
main =
    element
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
