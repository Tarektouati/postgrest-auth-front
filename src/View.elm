module View exposing (view)

import Html exposing (Attribute, Html, div, h1, span, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import List exposing (map)
import Message exposing (Msg(..))
import Types exposing (Model)
import UI.Form exposing (Input, User, customForm)
import UI.Modal exposing (modal)


type Block
    = FacebookBlock String
    | GoogleBlock String
    | SimpleBlock String


blocks : List Block
blocks =
    [ FacebookBlock "facebook", GoogleBlock "google", SimpleBlock "simple" ]


errorView : Maybe String -> Html Msg
errorView message =
    case message of
        Just error ->
            div [ class "error-view" ]
                [ span [ class "error-message" ] [ text error ]
                , span [ class "error-close", onClick CloseError ] []
                ]

        Nothing ->
            div [] []


toDiv : Block -> Html Msg
toDiv block =
    case block of
        FacebookBlock message ->
            span [ class message, onClick FacebookLogin ]
                [ h1 [ class (message ++ "-title") ] [ text message ]
                ]

        GoogleBlock message ->
            span [ class message, onClick GoogleLogin ]
                [ h1 [ class (message ++ "-title") ] [ text message ]
                ]

        SimpleBlock message ->
            span [ class message, onClick OpenModal ]
                [ h1 [ class (message ++ "-title") ] [ text message ]
                ]


emailInput : String -> Input
emailInput email =
    { type_ = "email"
    , placeHolder = "Email"
    , value = email
    }


passwordInput : String -> Input
passwordInput password =
    { type_ = "password"
    , placeHolder = "Password"
    , value = password
    }


rePasswordInput : String -> Input
rePasswordInput password =
    { type_ = "password"
    , placeHolder = "Repeat password"
    , value = password
    }


buildInputs : User -> List ( Input, String -> Msg )
buildInputs user =
    [ ( emailInput user.email
      , Email
      )
    , ( passwordInput user.password
      , Password
      )
    , ( rePasswordInput user.rePassword
      , RePassword
      )
    ]


signUpModal : Model -> Html Msg
signUpModal model =
    modal model.modal CloseModal [ customForm model.formUser SimpleLogin (buildInputs model.formUser) ]


view : Model -> Html Msg
view model =
    div []
        [ errorView model.error
        , div
            [ class "social" ]
            (map
                toDiv
                blocks
            )
        , signUpModal model
        ]
