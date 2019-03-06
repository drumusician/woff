defmodule WoffWeb.PageController do
  use WoffWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
