module View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (
    class, classList, href, id, placeholder, src, type'
    )
import Html.Events exposing (onInput)
import String as S

import Model exposing (Model, Msg(..), Item, Status(..))
import Utils exposing (splitInGroupsOf, slugify)


view: Model -> Html Msg
view model =
    div [ class "container" ]
        [ viewHeader
        , hr [] []
        , viewBody model
        , hr [] []
        , viewFooter
        ]


viewHeader : Html Msg
viewHeader =
    header []
           [ h1 [ class "text-center" ] [ text "Potlatch" ]
           , h5 [ class "text-center" ] [  text "A (virtual) gift-giving feast" ]
           , p [] [ text "I will leave Toronto at the end of June to go travel around the world! I  want to get rid of most of my belongings so that what's left can fit in a car."]
           , p [] [ text "Here are some of the items I am giving away! Let me know if you want any of them by messaging me at rafik@rafik.ca or through Facebook." ]
           , viewFilterForm
           ]


viewFilterForm : Html Msg
viewFilterForm =
    div [ class "row" ]
        [ div [ class "six columns offset-by-three"]
              [ input [ type' "search"
                      , class "u-full-width"
                      , placeholder "Filter items"
                      , onInput Filter
                      ]
                      [] ]
        ]

viewBody: Model -> Html Msg
viewBody model =
    case model.status of
        Loading ->
            div [ class "text-center" ]
                [ h4 [] [ text "Loading items..." ] ]
        Error err ->
            viewError err
        Done ->
            viewItems model


viewError : String -> Html Msg
viewError err =
    div [ class "text-center" ]
        [ h4 [] [ text "An error occured when fetching items" ]
        , p []
            [ strong [] [ text "Details: " ]
            , text err
            ]
        ]


filterItems : String -> List Item -> List Item
filterItems query items =
    let
        tags = query |> S.toLower |> S.words
        isValid tags name = List.all (\t -> S.contains t name) tags
    in
        List.filter ( isValid tags << S.toLower << .name ) items


viewItems : Model -> Html Msg
viewItems model =
    let
        visibleItems = filterItems model.query model.items
        (taken, available) = List.partition .taken visibleItems
    in
        div []
            [ h3 [ class "text-center" ] [ text "Available" ]
            , viewItemsSection available
            , hr [] []
            , h3 [ class "text-center" ] [ text "Already taken" ]
            , viewItemsSection taken
            ]


viewItemsSection : List Item -> Html Msg
viewItemsSection items =
    if List.isEmpty items then
        div []
            [ h5 [ class "text-center" ] [ text "No items" ]
            ]
    else
        let
            rows = Utils.splitInGroupsOf 2 items
        in
            div [] <| List.map viewRow rows


viewRow : List Item -> Html Msg
viewRow row =
    div [ class "row" ] <| List.map viewItem row


viewItem : Item -> Html Msg
viewItem item =
    let
        itemId = slugify item.name
        name = item.name ++ "!"
        description = Maybe.withDefault "" item.description
    in
        div [ class "one-half column" ]
            [ div [ id itemId, classList [("item", True), ("taken", item.taken)]]
                [ h3 [] [ text name ]
                , p [ class "description" ] [ text description ]
                , viewImage item
                ]
            ]


viewImage : Item -> Html Msg
viewImage item =
    let
        defaultImage = "./static/img/no-image.png"
        url = Maybe.withDefault defaultImage item.image
        imgContainer =
            if item.taken || url == defaultImage then
                div []
            else
                a [ href url ]
    in
        imgContainer
            [ img [ class "u-max-full-width", src url ] [] ]


viewFooter : Html Msg
viewFooter =
    footer [ class "text-center" ]
        [ span []
               [text "Made by "
               , a [ href "http://www.rafik.ca" ] [ text "Rafik Draoui" ]
               , text " using "
               , a [ href "http://elm-lang.org/" ] [ text "Elm" ]
               ]
        , span [ class "separator" ] [ text " • " ]
        , span []
               [text "Source code available on "
               , a [ href "https://github.com/rafikdraoui/potlatch" ] [ text "GitHub" ]
               ]
        ]
