module Utils exposing (splitInGroupsOf, nullOr, slugify)

import Json.Decode exposing (Decoder, null, oneOf)
import Char
import String as S


splitInGroupsOf : Int -> List a -> List (List a)
splitInGroupsOf n xs =
    if n < 1 || List.isEmpty xs then
        []
    else
        let
            prefix = List.take n xs
            rest = List.drop n xs
        in
            prefix :: splitInGroupsOf n rest


nullOr : Decoder a -> Decoder (Maybe a)
nullOr decoder =
    oneOf
    [ null Nothing
    , Json.Decode.map Just decoder
    ]



isValidCharForSlug : Char -> Bool
isValidCharForSlug c = Char.isLower c || Char.isDigit c || c == '-'


slugify : String -> String
slugify str =
    str
    |> S.toLower
    |> S.words
    |> List.map (S.filter isValidCharForSlug)
    |> List.filter (not << S.isEmpty)
    |> S.join "-"
