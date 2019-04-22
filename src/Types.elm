module Types exposing (SocialUser, User)


type alias User =
    { id : String
    , success : Bool
    }


type alias SocialUser =
    { id : String
    , email : String
    }
