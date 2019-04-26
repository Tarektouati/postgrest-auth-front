module Update exposing (Provider, update)

import Decoder exposing (decodeResponse, decodeSocialResponse)
import Encoder exposing (newUserEncoder, socialUserEncoder)
import Http
import Message exposing (Msg(..))
import Ports exposing (login, token)
import Types exposing (Model, SocialUser, User)
import UI.Form exposing (resetUser, updateEmail, updatePassword, updateRePassword)


type Provider
    = Google
    | Facebook


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OpenModal ->
            ( { model | modal = True }, Cmd.none )

        CloseModal ->
            ( { model | modal = False, formUser = resetUser model.formUser }, Cmd.none )

        Email email ->
            ( { model | formUser = updateEmail email model.formUser }, Cmd.none )

        Password password ->
            ( { model | formUser = updatePassword password model.formUser }, Cmd.none )

        RePassword password ->
            ( { model | formUser = updateRePassword password model.formUser }, Cmd.none )

        SimpleLogin ->
            ( model, simpleLogin model )

        FacebookLogin ->
            ( model, login "facebook" )

        GoogleLogin ->
            ( model, login "google" )

        SaveUser user ->
            ( { model | user = user }, Cmd.none )

        SaveSocialUser user ->
            ( { model | socialUser = user }, Cmd.none )

        PGGoogleLogin ->
            ( model, googleLogin model )

        PGFacebookLogin ->
            ( model, facebookLogin model )

        CloseError ->
            ( { model | error = Nothing }, Cmd.none )

        ShowError ->
            ( model, Cmd.none )

        SetToken response ->
            case response of
                Just payload ->
                    model
                        |> savedToken payload.token
                        |> (case payload.provider of
                                Just "google" ->
                                    loginTo Google payload.token

                                Just "facebook" ->
                                    loginTo Facebook payload.token

                                Just _ ->
                                    showError "Unable to login, retry again"

                                Nothing ->
                                    showError "Unable to login, retry again"
                           )

                Nothing ->
                    ( model, Cmd.none )

        SocialResult result ->
            case result of
                Ok user ->
                    user
                        |> resetToken model
                        |> savedSocialResponse user

                Err _ ->
                    showError "Unable to login, retry again" model

        LoginResult result ->
            case result of
                Ok user ->
                    user
                        |> resetForm model
                        |> savedResponse user

                Err _ ->
                    showError "Unable to login, retry again" model


simpleLogin : Model -> Cmd Msg
simpleLogin model =
    Http.post
        { url = model.endpoint ++ "/signup"
        , body = Http.jsonBody (newUserEncoder model.formUser)
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
    { model | modal = False, formUser = resetUser model.formUser }


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


showError : String -> Model -> ( Model, Cmd Msg )
showError errorMessage model =
    { model | error = Just errorMessage } |> update ShowError


resetToken : Model -> SocialUser -> Model
resetToken model _ =
    { model | accessToken = "" }


savedToken : String -> Model -> Model
savedToken token model =
    { model | accessToken = token }


loginTo : Provider -> String -> Model -> ( Model, Cmd Msg )
loginTo provider _ model =
    case provider of
        Google ->
            update PGGoogleLogin model

        Facebook ->
            update PGFacebookLogin model
