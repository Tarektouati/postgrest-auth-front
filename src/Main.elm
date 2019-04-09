module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Debug exposing (log, toString)
import Html exposing (Html, button, div, form, h1, img, input, p, span, text)
import Html.Attributes exposing (class, classList, disabled, placeholder, src, type_, value)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import List exposing (map)



---- MODEL ----


type alias User =
    { id : String
    , success : Bool
    }


type alias Model =
    { myModal : Bool
    , email : String
    , password : String
    , rePassword : String
    , savedData : User
    }


init : ( Model, Cmd Msg )
init =
    ( { myModal = False
      , email = ""
      , password = ""
      , rePassword = ""
      , savedData = { success = False, id = "" }
      }
    , Cmd.none
    )



---- UPDATE ----


items : List Block
items =
    [ Facebook "facebook", Google "google", Simple "simple" ]


type Block
    = Facebook String
    | Google String
    | Simple String


type Msg
    = OpenModal
    | CloseModal
    | Email String
    | Password String
    | RePassword String
    | SimpleLogin
    | LoginResult (Result Http.Error User)
    | FacebookLogin
    | GoogleLogin
    | Savedata User



--- simpleLogin: Model ->


newUserEncoder : String -> String -> Encode.Value
newUserEncoder email password =
    Encode.object
        [ ( "email", Encode.string email )
        , ( "password", Encode.string password )
        ]


simpleLogin : Model -> Cmd Msg
simpleLogin model =
    Http.post
        { url = "http://localhost:3001/signup"
        , body = Http.jsonBody (newUserEncoder model.email model.password)
        , expect = Http.expectJson LoginResult decodeResponse
        }


facebookLogin : Model -> Cmd Msg
facebookLogin model =
    Http.post
        { url = "http://localhost:3001/provider/facebook"
        , body = Http.jsonBody (newUserEncoder model.email model.password)
        , expect = Http.expectJson LoginResult decodeResponse
        }


googleLogin : Model -> Cmd Msg
googleLogin model =
    Http.post
        { url = "http://localhost:3001/provider/google"
        , body = Http.jsonBody (newUserEncoder model.email model.password)
        , expect = Http.expectJson LoginResult decodeResponse
        }


resetForm : Model -> User -> Model
resetForm model _ =
    { model | myModal = False, email = "", rePassword = "", password = "" }


savedResponse : User -> Model -> ( Model, Cmd Msg )
savedResponse resp model =
    update
        (Savedata
            resp
        )
        model


decodeResponse : Decode.Decoder User
decodeResponse =
    Decode.map2 User
        (Decode.at [ "id" ] Decode.string)
        (Decode.at [ "success" ] Decode.bool)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OpenModal ->
            ( { model | myModal = True }, Cmd.none )

        CloseModal ->
            ( { model | myModal = False, email = "", rePassword = "", password = "" }, Cmd.none )

        Email email ->
            ( { model | email = email }, Cmd.none )

        Password password ->
            ( { model | password = password }, Cmd.none )

        RePassword password ->
            ( { model | rePassword = password }, Cmd.none )

        SimpleLogin ->
            ( model, simpleLogin model )

        FacebookLogin ->
            ( model, facebookLogin model )

        Savedata data ->
            ( { model | savedData = data }, Cmd.none )

        GoogleLogin ->
            ( model, googleLogin model )

        LoginResult result ->
            case result of
                Ok resp ->
                    resp
                        |> resetForm model
                        |> savedResponse resp

                Err _ ->
                    ( model, Cmd.none )


toDiv : Block -> Html Msg
toDiv block =
    case block of
        Facebook message ->
            span [ class message, onClick FacebookLogin ]
                [ h1 [ class (message ++ "-title") ] [ text message ]
                ]

        Google message ->
            span [ class message, onClick GoogleLogin ]
                [ h1 [ class (message ++ "-title") ] [ text message ]
                ]

        Simple message ->
            span [ class message, onClick OpenModal ]
                [ h1 [ class (message ++ "-title") ] [ text message ]
                ]


buildInput : String -> String -> String -> (String -> msg) -> Html msg
buildInput inputType palceHolder inputValue toMsg =
    div [ class "form-items" ]
        [ p [ class "input-title" ]
            [ text palceHolder ]
        , input
            [ type_ inputType, class "input", placeholder palceHolder, onInput toMsg, value inputValue ]
            []
        ]


verifyForm : Model -> Bool
verifyForm model =
    not (String.isEmpty model.password)
        && (model.password == model.rePassword)
        && not (String.isEmpty model.email)


myForm : Model -> Html Msg
myForm model =
    div []
        [ form []
            [ buildInput "email" "Email" model.email Email
            , buildInput "password" "Password" model.password Password
            , buildInput "password" "Repeat password" model.rePassword RePassword
            , button [ class "submit-btn", onClick SimpleLogin, disabled (not (verifyForm model)) ] [ text "Sign up" ]
            ]
        ]


myModal : Model -> Html Msg
myModal model =
    div
        [ class "modal"
        , classList
            [ ( "active-modal", model.myModal )
            ]
        ]
        [ div [ class "modal-content" ]
            [ span [ class "close", onClick CloseModal ]
                []
            , p
                [ class "modal-title" ]
                [ text "Simple Sign up Form" ]
            , myForm model
            ]
        ]



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ div
            [ class "social" ]
            (map
                toDiv
                items
            )
        , myModal model
        ]



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }
