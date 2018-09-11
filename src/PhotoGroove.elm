module PhotoGroove exposing (..)

import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (..)

urlPrefix = "http://elm-in-action.com/"
 
view model =
    div [ class "content" ]
        [ h1 [] [ text "Photo Groove" ]
        , div [ id "thumbnails" ]
            (List.map (viewThumbnail model.selectedUrl) model.photos)
        , img
            [ class "large"
            , src (urlPrefix ++ "large/" ++ model.selectedUrl)
            ] []
        ]

viewThumbnail selected thumbnail =
    img [
        src (urlPrefix ++ thumbnail.url)
    ,   classList [ ( "selected", selected == thumbnail.url) ]
    ,   onClick { operation = "SELECT_PHOTO", data = thumbnail.url }
    ] []

initialModel =
    { photos =
        [
            { url = "1.jpeg" }
        ,   { url = "2.jpeg" }
        ,   { url = "3.jpeg" }
        ]
        , selectedUrl = "1.jpeg"
    }


update msg model =
    if msg.operation == "SELECT_PHOTO" then
        {model | selectedUrl = msg.data}
    else
        model


main =
    Html.beginnerProgram
    {   model = initialModel
      , view = view
      , update = update
    }
