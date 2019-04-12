module Types exposing (User, SocialUser)

type alias User =
    { id : String
    , success : Bool
    }

type alias SocialUser = 
    { id : String
    , email : String
    }