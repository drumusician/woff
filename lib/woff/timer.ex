defmodule Woff.Timer do
  use GenServer

  @timeout 1_000

  def start_link([]) do
    GenServer.start_link(__MODULE__, %{})
  end

  ## Server ##

  def init(_) do
    # this is where we get the number of seconds to the next WOFF
    {:ok, seconds_to_next_woff(), @timeout}
  end

  def handle_info(:timeout, 0) do
    broadcast(0, "WOFFTIME!")
    {:noreply, 0}
  end

  def handle_info(:timeout, time) do
    new_time = time - 1
    broadcast(new_time, format_duration(new_time))
    {:noreply, new_time, @timeout}
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
