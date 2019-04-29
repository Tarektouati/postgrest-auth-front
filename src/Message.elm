module Message exposing (Msg(..))

import Http
import Types exposing (Payload, SocialUser, User)


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
    | SetToken (Maybe Payload)
    | ShowError
    | CloseError
