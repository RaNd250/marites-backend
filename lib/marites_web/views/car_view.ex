defmodule MaritesWeb.CarView do
  use MaritesWeb, :view

  def render("command_failed.json", %{reason: reason}) do
    %{error: reason}
  end
end
