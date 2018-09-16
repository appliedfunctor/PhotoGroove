module PhotoGroove exposing (Model, Msg(..), Photo, ThumbnailSize(..), getPhotoUrl, initialModel, main, photoArray, randomPhotoPicker, sizeToString, stringToSize, update, urlPrefix, view, viewSizeChooser, viewThumbnail)

import Array exposing (Array)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http
import Random


type alias Photo =
    { url : String }


type alias Model =
    { photos : List Photo
    , selectedUrl : Maybe String
    , loadingError : Maybe String
    , chosenSize : ThumbnailSize
    }


type ThumbnailSize
    = Small
    | Medium
    | Large


type Msg
    = SelectPhotoByUrl String
    | SurpriseMe
    | SetSize ThumbnailSize
    | SelectByIndex Int
    | LoadPhotos (Result Http.Error String)


urlPrefix : String
urlPrefix =
    "http://elm-in-action.com/"


view : Model -> Html Msg
view model =
    div [ class "content" ]
        [ h1 [] [ text "Photo Groove" ]
        , button
            [ onClick SurpriseMe ]
            [ text "Surprise Me!" ]
        , div [ id "choose-size" ]
            (List.map (viewSizeChooser model.chosenSize) [ Small, Medium, Large ])
        , div [ id "thumbnails", class (sizeToString model.chosenSize) ]
            (List.map (viewThumbnail model.selectedUrl) model.photos)

        --, img
        --    [ class "large"
        --    , src (urlPrefix ++ "large/" ++ model.selectedUrl)
        --    ]
        --    []
        ]


viewThumbnail : Maybe String -> Photo -> Html Msg
viewThumbnail selected thumbnail =
    img
        [ src (urlPrefix ++ thumbnail.url)
        , classList [ ( "selected", selected == Just thumbnail.url ) ]
        , onClick (SelectPhotoByUrl thumbnail.url)
        ]
        []


viewSizeChooser : ThumbnailSize -> ThumbnailSize -> Html Msg
viewSizeChooser selectedSize size =
    label []
        [ input
            [ name "size"
            , type_ "radio"
            , checked (selectedSize == size)
            , onClick (SetSize size)
            ]
            []
        , text (sizeToString size)
        ]


sizeToString : ThumbnailSize -> String
sizeToString size =
    case size of
        Small ->
            "small"

        Medium ->
            "med"

        _ ->
            "large"


stringToSize : String -> ThumbnailSize
stringToSize size =
    case size of
        "small" ->
            Small

        "med" ->
            Medium

        _ ->
            Large


initialModel : Model
initialModel =
    { photos =
        [ { url = "1.jpeg" }
        , { url = "2.jpeg" }
        , { url = "3.jpeg" }
        ]
    , selectedUrl = Just "1.jpeg"
    , loadingError = Nothing
    , chosenSize = Medium
    }


photoArray : Array Photo
photoArray =
    Array.fromList initialModel.photos


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SelectPhotoByUrl url ->
            ( { model | selectedUrl = Just url }, Cmd.none )

        SurpriseMe ->
            ( model, Random.generate SelectByIndex randomPhotoPicker )

        SetSize size ->
            ( { model | chosenSize = size }, Cmd.none )

        SelectByIndex index ->
            ( { model | selectedUrl = Just (getPhotoUrl index) }, Cmd.none )

        LoadPhotos (Ok responseStr) ->
            let
                urls =
                    String.split "," responseStr

                photos =
                    List.map Photo urls
            in
            ( { model | photos = photos }, Cmd.none )

        LoadPhotos (Err _) ->
            ( model, Cmd.none )


getPhotoUrl : Int -> String
getPhotoUrl index =
    case Array.get index photoArray of
        Just photo ->
            photo.url

        Nothing ->
            ""


randomPhotoPicker : Random.Generator Int
randomPhotoPicker =
    Random.int 0 (Array.length photoArray - 1)


main =
    Html.program
        { init = ( initialModel, Cmd.none )
        , view = view
        , update = update
        , subscriptions = \model -> Sub.none
        }
