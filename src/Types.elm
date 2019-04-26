module Types exposing (Flags, Model, Payload, SocialUser, User)

import UI.Form as F


type alias User =
    { id : String
    , success : Bool
    }


type alias Payload =
    { token : String
    , provider : Maybe String
    }


type alias SocialUser =
    { id : String
    , email : String
    }


type alias Model =
    { modal : Bool
    , formUser : F.User
    , email : String
    , password : String
    , rePassword : String
    , user : User
    , socialUser : SocialUser
    , endpoint : String
    , state : String
    , accessToken : String
    , error : Maybe String
    }


type alias Flags =
    { api : String
    , state : String
    }
