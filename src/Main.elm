import Browser
import Html exposing (Html, text, button, span, input, div)
import Html.Attributes exposing (style, placeholder, value)
import Html.Events exposing (onInput)
import Http

import Protobuf.Encode
import Protobuf.Decode
import Reverse

type alias Model =
    { inputField : String
    , lastReversal : ReversalRelation
    }

type Msg
    = TextEntered String
    | TextReversed (Result Http.Error ReversalRelation)

type alias ReversalRelation = { original : String , reversed : String }

main = Browser.element
    { init = init
    , view = view
    , update = update
    , subscriptions = always Sub.none
    }

init : () -> ( Model , Cmd Msg )
init () =
    ( { inputField = "" , lastReversal = {original="", reversed=""} }
    , Cmd.none
    )

sendReverseRequest : String -> Cmd Msg
sendReverseRequest s =
    Http.post
        { url = "/api/reverse"
        , body = Http.bytesBody "application/octet-stream"
            <| Protobuf.Encode.encode
            <| Reverse.toReverseRequestEncoder { payload = s }
        , expect = Protobuf.Decode.expectBytes TextReversed
            <| Protobuf.Decode.map (\{result} -> {original=s, reversed=result})
            <| Reverse.reverseResponseDecoder
        }

view : Model -> Html Msg
view {inputField, lastReversal} =
    div []
        [ input [placeholder "text to reverse", onInput TextEntered, value inputField] []
        , if inputField == lastReversal.original
            then text lastReversal.reversed
            else span [style "color" "gray"] [text lastReversal.reversed]
        ]

update : Msg -> Model -> ( Model , Cmd Msg )
update msg model =
    case msg of
        TextEntered s ->
            ( { model | inputField = s }
            , sendReverseRequest s
            )
        TextReversed (Err e) -> Debug.todo "error-handling"
        TextReversed (Ok relation) ->
            ( if relation.original == model.inputField
                then { model | lastReversal = relation }
                else model
            , Cmd.none
            )
