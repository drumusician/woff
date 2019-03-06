At the Kabisa Amsterdam Team (a.k.a. KAT) office we have a nice tradition every Friday, World of Food Friday's, or in short, WOFF. It brings our team together and let's all of us sync in as we are often busy on many different projects during the week. We go out for lunch at a place called World of Food, which is basically a marketplace with all kinds of small food stands with the best food from all over the world. The nice thing is that you can pick and choose what you like and then all sit together and enjoy a nice meal, while discussing all our experiences from the past week. 

Now I started to think about this and found this scenario to be very similar to the choices we have to make during the startup of a new project. First of all the choice of technology in the vast World of Frontend Frameworks(WOFF :0), all developers do have their own preferred meal. But not only just the choice in what framework to use for the frontend but also the choice between going with a Single Page Application(SPA) or a Server Side Rendered Application(SSRA). These days I think people tend to grab an SPA framework far too quickly, and I believe that is mainly because they are afraid that it'll become hard to integrate an SSRA with an SPA after the start of the project. These days many technologies provide a backend that servers pages really quickly that the choice of an SPA does not merely become a matter of page load speeds, but rather a choice of needing the in-page interaction. In this post I like to explore the way we can use an SSRA and add Frontend Components as we go along, without necessarily limiting ourselves to a specific framework.

We'll start by setting up a basic SSRA using the awesome Phoenix Framework. Using the Phoenix generator this is very straightforward. For this we'll need to have Elixir and Phoenix installed. For instruction please refer to their guides [here](https://elixir-lang.org/install.html) and [here](https://hexdocs.pm/phoenix/installation.html). Once that is ready we can generate our projec like this:

```shell
mix phx.new woff --no-ecto
```

I've left out ecto, because we really don't need a database for this.

While this gives us a good starting point, I have come accross a setup someone implemented that has all the config(so also for webpack) in the root of the project. So you don't have to switch to the assets folder constantly, which makes this setup kind of nice. For convenience I have created a little generator that will convert a new phoenix project into this setup. So you can install and run that using my baco project.

```shell
mix archive.install hex baco
```

Then inside of your Phoenix Project:
```shell
mix convert.phx_root_config
```

Then we need to make one final change to make sure that webpack is happy in dev.exs. Make sure the watchers entry is the same as below:

```elixir
watchers: [
  {"node", [
    "node_modules/webpack/bin/webpack.js",
    "--watch-stdin",
    "--colors"
  ]}
]
```

For the purpose of this post we'll create a page in our Phoenix project to host our frontend components. And because we always like to now how long we have to wait until the next WOFF, we'll implement a countdown timer that counts down to the next World of Food Friday (that means the next Friday, noon). We'll see if we can actually add multiple timers using different frontend frameworks in one page, just for the fun of it :)

### Template

The phoenix generator comes out of the box with a PageController and an index template, so we'll go the easy route and just use that for our timer page. We'll start by wiping the contents of the template and add some minimal styling and markup to hold our timers. Phoenix comes with a minimalist css framework ([Milligram](https://milligram.io/)), but that's just a bit too minimal for my taste. For this little project I decided to try out [Bulma](https://bulma.io/), another minimalist css framwework based on flexbox. And let's switch to sass as well.

```bash
mv assets/css assets/scss
mv assets/scss/app.css assets/scss/app.scss
yarn add bulma node-sass sass-loader
```

```scss
// assets/scss/app.scss

@import 'bulma';

.timer {
	align-items: center;
	display: flex;
	justify-content: space-evenly;
}
```

```js
// webpack.config.js
...
entry: {
    app: ['./assets/js/app.js', './assets/scss/app.scss']
},
...
```

And we'll add some markup to the layout and index pages:

```elixir
# lib/woff_web/templates/app.html.eex
...
<section class="hero is-primary">
  <div class="hero-body">
    <div class="container">
      <h1 class="title">
        Time to WOFF
      </h1>
      <h2 class="subtitle">
        Every Friday at 12 pm
      </h2>
    </div>
  </div>
</section>
...
```

```elixir
<section class="section has-background-light">
	<div class="container">
		<div class="columns">
			<div class="column">
				<div class="notification is-link">
					<div class="timer">
						<img src="images/react.png" width="75px" height="75px" \>
						<div id="react-timer"></div>
					</div>
				</div>
			</div>
			<div class="column">
				<div class="notification is-info has-background-grey-dark">
					<div class="timer">
						<img src="images/elm.png" width="75px" height="75px" \>
						<div id="elm-counter"></div>
					</div>
				</div>
			</div>
			<div class="column">
				<div class="notification is-primary">
					<div class="timer">
						<img src="images/phoenix.png" width="75px" height="75px" \>
						<h1 class="is-size-6 center" id="elixir-timer"></h1>
					</div>
				</div>
			</div>
		</div>
	</div>
</section>
```

You'll see I have already added 3 slots for 3 different timers. One using React, one for Elm and the last one using LiveView. Although LiveView is currently not ready yet, I think it is a good option for this purpose as well.

### React

So how do we add our React Component into this div...? There is a nice little hex package that makes rendering reat component in elixir templates a breeze, [react_phoenix](https://hex.pm/packages/react_phoenix). But for this post I wanted to see if I can make it work without using any extra dependencies. So just using React and ReactDOM we should be able to render a component in a div very easily. We do need to install react and react-dom and some babel stuff, and also configure webpack to handle jsx files.

```bash
yarn add react react-dom @babel/preset-react @babel/plugin-proposal-class-properties
```

```js
// webpack.config.js
...
rules: [
  {
    test: /\.(js|jsx)$/,
    exclude: /node_modules/,
    use: {
      loader: 'babel-loader'
    }
  },
...
```

```js
// .babelrc
{
  "presets": [
      "@babel/preset-env",
      "@babel/preset-react"
  ],
  "plugins": [
      "@babel/plugin-proposal-class-properties"
  ]
}
```

We'll name our react component Timer and add it in `assets/js/components`. The div we will render it in is going to be `'react-timer'`. So putting this all in app.js results in the following:

```js
...
import React from 'react'
import ReactDOM from 'react-dom
...

// render React Component into a specified DIV
import Timer from './components/timer'
ReactDOM.render(<Timer />, document.getElementById('react-timer'))
```

And that's all we need to do to get it to work. That was easy! Let's create a minimal React component now to see if this actually works... :)

```jsx
import React from 'react';

export default class Timer extends React.Component {
  render() {
    return (<div>
      <p>Hello React Timer</p>
    </div>
    )
  }
}
```
And it works!

Now, this post is not specifically about React or implementation details of a Timer, so I won't go into detail into that for this post. Here is the React Timer:

```jsx
import React from 'react';

const initialState = {
  timediff: 0,
  intervalHandle: 0,
  days: 0,
  hours: 0,
  minutes: 0,
  seconds: 0
}

const padTime = (value) => {
  if (value < 10) {
    return `0${value}`;
  } else {
    return value;
  }
}

export default class Timer extends React.Component {
  constructor(props) {
    super(props)

    // Set the initial state of the component in a constructor.
    this.state = initialState
  }

  componentDidMount = () => {
    const timediff = this.timeToWoff();
    const {days, hours, minutes, seconds} = this.getTime(timediff);
    const intervalHandle = setInterval(this.tick, 1000);

    this.setState({
      timediff: timediff,
      intervalHandle: intervalHandle,
      days: days,
      hours: hours,
      minutes: minutes,
      seconds: seconds
    });

  }

  render() {
    return (
      <span>
        {(this.state.days > 0) ? `${this.state.days} days ` : ''}
        {padTime(this.state.hours)}:
        {padTime(this.state.minutes)}:
        {padTime(this.state.seconds)}
      </span>
    )
  }

  tick = () => {
    const { days, hours, minutes, seconds } = this.getTime(this.state.timediff - 1);

    if (hours === 0 && minutes === 0 && seconds === 0) {
      clearInterval(this.state.intervalHandle);
    }

    this.setState({
      timediff: this.state.timediff -1,
      days: days,
      hours: hours,
      minutes: minutes,
      seconds: seconds
    });
  }

  getTime = (timediff) =>  {
    const days = Math.floor(timediff / 86400)
    const hours = Math.floor((timediff - days * 86400) / 3600);
    timediff -= hours * 3600;
    const minutes = Math.floor(timediff / 60) % 60;
    timediff -= minutes * 60;
    const seconds = timediff % 60;

    return {
      days, hours, minutes, seconds
    }
  }

  timeToWoff = () => {
    const date = new Date();
    date.setDate(date.getDate() + (5 + 7 - date.getDay()) % 7);
    date.setHours(12);
    date.setMinutes(0);
    date.setSeconds(0);
    return Math.abs(date - Date.now()) / 1000;
  }
}
```

### Elm

For the second component I'd like to see how easy it would be to add Elm to the mix.

So let's first install elm:

```bash
yarn add elm elm-webpack-loader
```

And here is an elm.json config file to use. You can also generate this with elm init, but I've added it here for convenience. All the credit for the Elm Timer implementation goes to my colleague Tonći Galić, as I haven't played with Elm that much yet...

```js
// elm.json
{
  "type": "application",
  "source-directories": [
      "assets/elm/src"
  ],
  "elm-version": "0.19.0",
  "dependencies": {
      "direct": {
          "elm/browser": "1.0.1",
          "elm/core": "1.0.2",
          "elm/html": "1.0.0",
          "elm/time": "1.0.0",
          "justinmimbs/time-extra": "1.1.0"
      },
      "indirect": {
          "elm/json": "1.1.3",
          "elm/parser": "1.1.0",
          "elm/url": "1.0.0",
          "elm/virtual-dom": "1.0.2",
          "justinmimbs/date": "3.1.2"
      }
  },
  "test-dependencies": {
      "direct": {},
      "indirect": {}
  }
}
```

And here is how we pull in the Elm Timer from the implementation.

```js
// app.js
...
// Elm Program
import { Elm } from "../elm/src/Timer.elm"
const elmDiv = document.getElementById('elm-counter');

Elm.Timer.init({ node: elmDiv })
...
```

And this is the full implementation for the Elm Timer.

```elm
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

```

For the last timer I wanted to actually use LiveView, but after reading Chris' blog post on how to do that I discovered that the implementation is actually not publicly available yet. So I decided to roll my own GenServer implementation that mimics the functionality of LiveView a bit using Phoenix Channels.

First we'll need to import the socket in app.js

```js
...
// app.js
import './socket.js'
...
```

And set up the connection in socket.js

```js
import {Socket} from "phoenix"

let socket = new Socket("/socket", {params: {token: window.userToken}})
socket.connect()

// Now that you are connected, you can join channels with a topic:
let channel = socket.channel("timer:update", {})
channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

channel.on('new_time', payload => {
	document.getElementById('elixir-timer').innerText = payload.response
})

export default socket
```

Now we'll need to add the channel responsible for pushing updates over the socket.

```elixir
# lib/woff_web/channels/timer_channel.ex

defmodule WoffWeb.TimerChannel do
  use Phoenix.Channel

  def join("timer:update", _msg, socket) do
    {:ok, socket}
  end

  def handle_in("new_time", msg, socket) do
    push socket, "new_time", msg
    {:noreply, socket}
  end
end
```

And finally we'll add the implementation details in a GenServer

```elixir
defmodule Woff.Timer do
  use GenServer

  def start_link([]) do
    GenServer.start_link(__MODULE__, %{})
  end

  ## Server ##

  def init(_) do
    # this is where we get the number of seconds to the next WOFF
    schedule_timer(1_000)
    {:ok, seconds_to_next_woff()}
  end

  def handle_info(:update, 0) do
    broadcast(0, "WOFFTIME!")
    {:noreply, 0}
  end

  def handle_info(:update, time) do
    new_time = time - 1
    broadcast(new_time, format_duration(new_time))
    schedule_timer(1_000)
    {:noreply, new_time}
  end

	defp format_duration(unix_time) do
    days = div(unix_time, 86400)
		{hours, remaining} = { div(unix_time - days * 86400, 3600), rem(unix_time, 3600) }
		{minutes, seconds} = { div(remaining, 60), rem(remaining, 60) }
    stringify_date({days, hours, minutes, seconds})
  end

  defp stringify_date({days, hours, minutes, seconds}) when days == 0 do
    "#{pad_digit(hours)}:#{pad_digit(minutes)}:#{pad_digit(seconds)}"
  end

  defp stringify_date({days, hours, minutes, seconds}) do
    "#{days} days #{pad_digit(hours)}:#{pad_digit(minutes)}:#{pad_digit(seconds)}"
  end

  defp pad_digit(digit) do
    digit
    |> to_string
    |> String.pad_leading(2, "0")
  end

  defp schedule_timer(interval) do
    Process.send_after(self(), :update, interval)
  end

  defp broadcast(time, response) do
    payload = %{
      time: time,
      response: response
    }
    WoffWeb.Endpoint.broadcast!("timer:update", "new_time", payload)
  end

  defp seconds_to_next_woff do
    {:ok, datetime} = DateTime.now("Europe/Amsterdam")

    next_woff_time(datetime) - DateTime.to_unix(datetime)
  end

  defp next_woff_time(datetime) do
    date = datetime |> DateTime.to_date

    day_of_the_week =
      date
      |> Date.day_of_week

    days_till_friday = rem((12 - day_of_the_week), 7)
    next_woff_date = next_woff_date(datetime, days_till_friday)

		DateTime.to_unix(%DateTime{ next_woff_date | hour: 12, minute: 0, second: 0 })
  end

  defp next_woff_date(%DateTime{hour: hour} = datetime, days_till_friday)
    when hour < 12 and days_till_friday == 0 do
    datetime
  end

  defp next_woff_date(datetime, days_till_friday) when days_till_friday == 0 do
    DateTime.add(datetime, (7 * 3600 * 24), :second)
  end

  defp next_woff_date(datetime, days_till_friday) do
    DateTime.add(datetime, (days_till_friday * 3600 * 24), :second)
  end
end

```

Now of course the implementations of the Timer are a fair bit of work, but the goal of this post was to see how straightforward it would be to add different Javascript Libraries on a page as components. I was very surprised that this is not difficult at all and this gives us some great ways to just add interactive client-side components where needed and handle the main serving of pages that don't need this to the server. I like this approach as it gives me the advantages of both and I can now decide what works best feature by feature.
Now that I have figured this out it is time to build something real. So let's see what I come up with in a feature post... 

Until next `time`
