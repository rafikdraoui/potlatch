module Model exposing
    (init
    , update
    , Model
    , Msg(..)
    , Item
    , Status(..)
    )

import Http
import Json.Decode exposing
    ((:=)
    , bool
    , list
    , maybe
    , object4
    , string
    , Decoder
    )
import Task

import Utils exposing (nullOr)


type alias Url = String


type alias Item =
    { name : String
    , description : Maybe String
    , image : Maybe Url
    , taken : Bool
    }

type Status
    = Loading
    | Error String
    | Done


type alias Model =
    { items : List Item
    , status : Status
    , query : String
    }


type Msg
    = FetchSuccess (List Item)
    | FetchFailure Http.Error
    | Filter String


init : { itemsUrl : String } -> (Model, Cmd Msg)
init { itemsUrl } = { items = [],  status = Loading, query = "" } ! [ fetchItems itemsUrl ]


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        FetchSuccess items ->
            { model | items = items , status = Done } ! []
        FetchFailure err ->
            { model | status = Error (toString err) } ! []
        Filter query ->
            { model | query = query } ! []


items : Decoder (List Item)
items =
    let
        item =
            object4 Item
                ("name" := string)
                ("description" := nullOr string)
                ("image" := nullOr string)
                ("taken" := bool)
    in
        list item


fetchItems : Url -> Cmd Msg
fetchItems url =
    let
        task = Http.get ("items" := items) url
    in
        Task.perform FetchFailure FetchSuccess task
