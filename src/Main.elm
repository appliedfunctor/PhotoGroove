module Main exposing (Model, Msg(..), Photo, ThumbnailSize(..), initialCmd, initialModel, main, sizeToString, stringToSize, update, urlPrefix, view, viewLarge, viewSizeChooser, viewThumbnail)

import Array exposing (Array)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http
import Random


type alias Photo =
    { url : String

    --, size : Int
    --, title : String
    }


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
        , viewLarge model.selectedUrl
        ]


viewOnError : Model -> Html Msg
viewOnError model =
    case model.loadingError of
        Nothing ->
            view model

        Just errorMessage ->
            div [ class "error-message" ]
                [ h1 [] [ text "Photo Groove" ]
                , p [] [ text errorMessage ]
                , img [ src "https://media.giphy.com/media/27EhcDHnlkw1O/giphy.gif" ] []
                ]


viewLarge : Maybe String -> Html Msg
viewLarge maybeUrl =
    case maybeUrl of
        Nothing ->
            text ""

        Just url ->
            img [ class "large", src (urlPrefix ++ "large/" ++ url) ] []


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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SelectPhotoByUrl url ->
            ( { model | selectedUrl = Just url }, Cmd.none )

        SurpriseMe ->
            let
                randomPhotoPicker =
                    Random.int 0 (List.length model.photos - 1)
            in
            ( model, Random.generate SelectByIndex randomPhotoPicker )

        SetSize size ->
            ( { model | chosenSize = size }, Cmd.none )

        SelectByIndex index ->
            let
                newSelectedUrl : Maybe String
                newSelectedUrl =
                    model.photos
                        |> Array.fromList
                        |> Array.get index
                        |> Maybe.map .url
            in
            ( { model | selectedUrl = newSelectedUrl }, Cmd.none )

        LoadPhotos (Ok responseStr) ->
            let
                urls =
                    String.split "," responseStr

                photos =
                    List.map Photo urls

                head =
                    photos
                        |> List.head
                        |> Maybe.map .url
            in
            ( { model | photos = photos, selectedUrl = head }, Cmd.none )

        LoadPhotos (Err error) ->
            ( { model | loadingError = Just (htmlErrorFormat error) }, Cmd.none )


htmlErrorFormat : Http.Error -> String
htmlErrorFormat err =
    case err of
        Http.BadStatus error ->
            "Error '"
                ++ toString error.status.code
                ++ " "
                ++ error.status.message
                ++ "' received from "
                ++ error.url

        _ ->
            toString err


initialModel : Model
initialModel =
    { photos = []
    , selectedUrl = Nothing
    , loadingError = Nothing
    , chosenSize = Medium
    }


initialCmd : Cmd Msg
initialCmd =
    "http://elm-in-action.com/photos/list"
        |> Http.getString
        |> Http.send LoadPhotos


main : Program Never Model Msg
main =
    Html.program
        { init = ( initialModel, initialCmd )
        , view = viewOnError
        , update = update
        , subscriptions = \_ -> Sub.none
        }
