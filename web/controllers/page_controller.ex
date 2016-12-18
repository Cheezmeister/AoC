defmodule Aoc.PageController do
  use Aoc.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
