module UI.Form exposing (Input, User, customForm, initUser, resetUser, updateEmail, updatePassword, updateRePassword)

import Html exposing (Attribute, Html, button, div, form, h1, input, p, span, text)
import Html.Attributes exposing (class, classList, disabled, placeholder, type_, value)
import Html.Events exposing (custom, onClick, onInput)
import Json.Decode as Decode
import List exposing (..)


type alias User =
    { email : String
    , password : String
    , rePassword : String
    }


type alias Input =
    { type_ : String
    , placeHolder : String
    , value : String
    }


initUser : User
initUser =
    { email = ""
    , password = ""
    , rePassword = ""
    }


resetUser : User -> User
resetUser user =
    { email = "", password = "", rePassword = "" }


updateEmail : String -> User -> User
updateEmail email user =
    { user | email = email }


updatePassword : String -> User -> User
updatePassword password user =
    { user | password = password }


updateRePassword : String -> User -> User
updateRePassword password user =
    { user | rePassword = password }


verifyForm : User -> Bool
verifyForm user =
    not (String.isEmpty user.password)
        && (user.password == user.rePassword)
        && not (String.isEmpty user.email)


buildInput : String -> String -> String -> (String -> msg) -> Html msg
buildInput inputType palceHolder inputValue toMsg =
    div [ class "form-items" ]
        [ p [ class "input-title" ]
            [ text palceHolder ]
        , input
            [ type_ inputType, class "input", placeholder palceHolder, onInput toMsg, value inputValue ]
            []
        ]


toInputs : ( Input, String -> msg ) -> Html msg
toInputs ( field, msg ) =
    buildInput field.type_ field.placeHolder field.value msg


preventDefaultOpts : msg -> Html.Attribute msg
preventDefaultOpts message =
    custom
        "submit"
        (Decode.succeed { preventDefault = True, stopPropagation = False, message = message })


submitBtn : User -> msg -> Html msg
submitBtn user toMsg =
    button [ class "submit-btn", onClick toMsg, disabled (not (verifyForm user)) ] [ text "Sign up" ]


customForm : User -> msg -> List ( Input, String -> msg ) -> Html msg
customForm user toMsg inputs =
    div []
        [ form
            [ preventDefaultOpts toMsg ]
            (let
                htmlInputs =
                    map toInputs inputs
             in
             append htmlInputs [ submitBtn user toMsg ]
            )
        ]
