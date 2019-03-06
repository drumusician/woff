module Timer exposing (Msg(..), main, update, view)

import Browser
import Html exposing (Html, button, div, h1, text)
import Html.Events exposing (onClick)
import Task
import Time
import Time.Extra as T
import Debug exposing (toString)

main =
    Browser.element { init = initialModel
                    , update = update
                    , view = view
                    , subscriptions = subscriptions
                    }


--type alias Time =
--    Float


type alias Model =
    { expirationTime : Time.Posix
    , remainingSeconds : Int
    , status : Status
    , zone : Time.Zone
    }


initialModel : () -> (Model, Cmd Msg)
initialModel _ =
    ( Model (Time.millisToPosix 0) 0 Running Time.utc
    , Task.perform AdjustTimeZone Time.here
    )


getNextWoff =
    Task.perform AdjustNextWoff Time.now


type Status
    = Running
    | Expired


type Msg
    = Init
    | AdjustTimeZone Time.Zone
    | AdjustNextWoff Time.Posix
    | Tick Time.Posix

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Init ->
            initialModel ()

        AdjustTimeZone newTimeZone ->
            ( {model | zone = newTimeZone}
            , Task.perform AdjustNextWoff Time.now
            )

        AdjustNextWoff now ->
            let
                nextWoffDay = T.posixToParts model.zone <| T.ceiling T.Friday model.zone now
                {year, month, day} = nextWoffDay
                nextWoff = T.ceiling T.Second model.zone (T.partsToPosix model.zone (T.Parts year month day 12 0 0 0))
            in
                ({model | expirationTime = nextWoff}, Cmd.none)

        Tick newTime->
            ( {model | remainingSeconds = (T.diff T.Second Time.utc newTime model.expirationTime)}
            , Cmd.none
            )

view : Model -> Html Msg
view model =
    div []
        [ h1 [ onClick Init ] [ text <| formatRemaining model.remainingSeconds ]
        ]

subscriptions : Model -> Sub Msg
subscriptions model =
  Time.every 1000 Tick


formatRemaining : Int -> String
formatRemaining remainingSeconds =
    let
        days = remainingSeconds // 86400
        hours = (remainingSeconds - days * 86400) // 3600
        minutes = (remainingSeconds - (days * 86400) - (hours * 3600)) // 60
        seconds = remainingSeconds - (days * 86400) - (hours * 3600) - (minutes * 60)
        daysString = if days > 0 then (toString days) ++ " days " else ""
    in
            daysString ++ (toString hours) ++ ":" ++ (toString minutes) ++ ":" ++ (toString seconds)
