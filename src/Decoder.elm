module Decoder exposing (decodeResponse, decodeSocialResponse)

import Json.Decode as Decode
import Types exposing (SocialUser, User)


decodeSocialResponse : Decode.Decoder SocialUser
decodeSocialResponse =
    Decode.map2 SocialUser
        (Decode.at [ "user", "id" ] Decode.string)
        (Decode.at [ "user", "email" ] Decode.string)


decodeResponse : Decode.Decoder User
decodeResponse =
    Decode.map2 User
        (Decode.at [ "id" ] Decode.string)
        (Decode.at [ "success" ] Decode.bool)
