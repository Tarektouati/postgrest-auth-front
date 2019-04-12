module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Browser.Navigation as Navigation exposing (Key)
import Debug exposing (log, toString)
import Encoder exposing (newUserEncoder, socialUserEncoder)
import Html exposing (Html, button, div, form, h1, img, input, p, span, text, Attribute, node)
import Html.Attributes exposing (class, classList, disabled, placeholder, src, type_, value )
import Html.Events exposing (custom, onClick, onInput)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import List exposing (map)
import Types exposing (User, SocialUser)
import Url exposing (Protocol(..), Url)
import Ports exposing (login, token, Payload)


---- MODEL ----


type Provider = Google | Facebook

type alias Flags =
    { api : String
    , state : String
    }


type alias Model =
    { myModal : Bool
    , email : String
    , password : String
    , rePassword : String
    , user : User
    , googleUser : SocialUser
    , endpoint : String
    , state : String
    , accessToken : String
    , error : String
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { myModal = False
      , email = ""
      , password = ""
      , rePassword = ""
      , endpoint = flags.api
      , state = flags.state
      , accessToken = ""
      , user = {  id = "" , success = False}
      , googleUser = {id = "", email =""}
      , error = ""
      }
    , Cmd.none
    )


---- UPDATE ----


blocks : List Block
blocks =
    [ FacebookBlock "facebook", GoogleBlock "google", SimpleBlock "simple" ]


type Block
    = FacebookBlock String
    | GoogleBlock String
    | SimpleBlock String


type Msg
    = OpenModal
    | CloseModal
    | Email String
    | Password String
    | RePassword String
    | SimpleLogin
    | LoginResult (Result Http.Error User)
    | SocialResult (Result Http.Error SocialUser)
    | FacebookLogin
    | GoogleLogin
    | PGGoogleLogin
    | PGFacebookLogin
    | SaveUser User
    | SaveSocialUser SocialUser
    | SetToken( Maybe Payload)




simpleLogin : Model -> Cmd Msg
simpleLogin model =
    Http.post
        { url = model.endpoint ++ "/signup"
        , body = Http.jsonBody (newUserEncoder model.email model.password)
        , expect = Http.expectJson LoginResult decodeResponse
        }


facebookLogin : Model -> Cmd Msg
facebookLogin model =
    Http.post
        { url = model.endpoint ++ "/provider/facebook"
        , body = Http.jsonBody (socialUserEncoder model.state model.password)
        , expect = Http.expectJson SocialResult decodeSocialResponse
        }


googleLogin : Model -> Cmd Msg
googleLogin model =
    Http.post
        { url = model.endpoint ++ "/provider/google"
        , body = Http.jsonBody (socialUserEncoder model.state model.accessToken)
        , expect = Http.expectJson SocialResult decodeSocialResponse
        }


resetForm : Model -> User -> Model
resetForm model _ =
    { model | myModal = False, email = "", rePassword = "", password = "" }


savedResponse : User -> Model -> ( Model, Cmd Msg )
savedResponse user model =
    update
        (SaveUser
            user
        )
        model

savedSocialResponse : SocialUser -> Model -> ( Model, Cmd Msg )
savedSocialResponse user model =
    update
        (SaveSocialUser
            user
        )
        model        

decodeSocialResponse : Decode.Decoder SocialUser
decodeSocialResponse =
    Decode.map2 SocialUser
        (Decode.at [ "user","id" ] Decode.string)
        (Decode.at [ "user", "email" ] Decode.string)


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
            ( model, login "facebook" )
        GoogleLogin ->
            --- TODOOOOO ----
            ( model, login "google" )

        SaveUser user ->
            ( { model | user = user }, Cmd.none )

        SaveSocialUser user ->
            ( { model | googleUser = user }, Cmd.none )

        PGGoogleLogin -> 
             ( model, googleLogin model )
        PGFacebookLogin -> 
             ( model, facebookLogin model )
    
        SetToken response ->
            case response of
                Just payload  -> 
                    model
                        |> savedToken payload.token
                        |> case payload.provider of
                            Just "google" -> loginTo Google payload.token
                            Just "facebook" -> loginTo Facebook payload.token
                            Just _ -> loginTo Facebook payload.token
                            Nothing -> loginTo Facebook payload.token

                Nothing -> (model , Cmd.none)
        SocialResult result -> 
            case result of
                Ok user ->
                    user
                        |> resetToken model
                        |> savedSocialResponse user

                Err err ->
                {-- TODOOO handler error---}
                   ( {model| error = (Debug.toString err)}, Cmd.none )
        LoginResult result ->
            case result of
                Ok user ->
                    user
                        |> resetForm model
                        |> savedResponse user

                Err err ->
                    
                    ( {model| error = (Debug.toString err)}, Cmd.none )


resetToken : Model -> SocialUser -> Model 
resetToken model _  = { model | accessToken = "" }

savedToken : String -> Model -> Model 
savedToken token model =
 { model | accessToken = token }

loginTo : Provider -> String -> Model -> ( Model, Cmd Msg )
loginTo provider _ model =
    case provider of
        Google ->  update (PGGoogleLogin) model
        Facebook ->  update (PGFacebookLogin) model

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



---- VIEW BUILDER ----


verifyForm : Model -> Bool
verifyForm model =
    not (String.isEmpty model.password)
        && (model.password == model.rePassword)
        && not (String.isEmpty model.email)


buildInput : String -> String -> String -> (String -> msg) -> Html msg
buildInput inputType palceHolder inputValue toMsg =
    div [ class "form-items" ]
        [ p [ class "input-title" ]
            [ text palceHolder ]
        , input
            [ type_ inputType, class "input", placeholder palceHolder, onInput toMsg, value inputValue ]
            []
        ]


preventDefaultOpts : Msg -> Html.Attribute Msg
preventDefaultOpts message =
    custom
        "submit"
        (Decode.succeed { preventDefault = True, stopPropagation = False, message = message })


myForm : Model -> Html Msg
myForm model =
    div []
        [ form
            [ preventDefaultOpts SimpleLogin ]
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
                blocks
            )
        , myModal model
        ]



--- SUBS ------


subscriptions : Model -> Sub Msg
subscriptions model =
    token SetToken 



---- PROGRAM ----


main : Program Flags Model Msg
main =
    Browser.element
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
