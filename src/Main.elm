module Main exposing (main)

import Html.App as App

import Model
import View


main : Program { itemsUrl : String }
main =
    App.programWithFlags
        { init = Model.init
        , update = Model.update
        , subscriptions = \_ -> Sub.none
        , view = View.view
        }
