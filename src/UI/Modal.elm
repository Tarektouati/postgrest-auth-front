module UI.Modal exposing (modal)

import Html exposing (Attribute, Html, div, p, span, text)
import Html.Attributes exposing (class, classList)
import Html.Events exposing (onClick)
import List exposing (map)


modal : Bool -> msg -> List (Html msg) -> Html msg
modal isActive message childs =
    div
        [ class "modal"
        , classList
            [ ( "active-modal", isActive )
            ]
        ]
        [ div [ class "modal-content" ]
            [ span [ class "close", onClick message ]
                []
            , p
                [ class "modal-title" ]
                [ text "Simple Sign up Form" ]
            , div [] (map (\child -> child) childs)
            ]
        ]
