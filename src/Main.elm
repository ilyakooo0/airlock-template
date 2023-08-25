port module Main exposing (main)

import Browser exposing (Document)
import Html exposing (..)
import Json.Decode as JD
import Ur
import Ur.Cmd
import Ur.Run
import Ur.Sub


url : String
url =
    "http://localhost:8080"


main : Ur.Run.Program Model Msg
main =
    Ur.Run.application
        { init =
            \_ _ ->
                ( { ship = Nothing }
                , Cmd.batch
                    [ Ur.logIn url "lidlut-tabwed-pillex-ridrup"
                        |> Cmd.map (always Noop)
                    , Ur.getShipName url |> Cmd.map (result (always Noop) GotShipName)
                    ]
                    |> Ur.Cmd.cmd
                )
        , update = update
        , view = view
        , subscriptions = always Sub.none
        , createEventSource = createEventSource
        , urbitSubscriptions = \{} -> Ur.Sub.none
        , onEventSourceMsg = onEventSourceMessage
        , onUrlChange = \_ -> Noop
        , onUrlRequest = \_ -> Noop
        , urbitUrl = \_ -> url
        }


type alias Model =
    { ship : Maybe String }


type Msg
    = Noop
    | GotShipName String


update : Msg -> Model -> ( Model, Ur.Cmd.Cmd Msg )
update msg model =
    case msg of
        Noop ->
            ( model, Ur.Cmd.none )

        GotShipName name ->
            ( { model | ship = Just name }, Ur.Cmd.none )


view : Model -> Document Msg
view {} =
    { body = [ text "Welcome to Urbit" ]
    , title = "Airlock"
    }


result : (a -> c) -> (b -> c) -> Result a b -> c
result f g res =
    case res of
        Ok b ->
            g b

        Err a ->
            f a


port createEventSource : String -> Cmd msg


port onEventSourceMessage : (JD.Value -> msg) -> Sub msg
