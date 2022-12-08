defmodule DigitsWeb.PageLive.Index do
  @moduledoc """
  PageLive LiveView
  """

  use DigitsWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, %{prediction: nil})}
  end

  def render(assigns) do
    ~H"""
    <.cool_layout />
    <div class="px-4 py-10 sm:py-28 sm:px-6 lg:px-8 xl:py-32 xl:px-28">
      <div id="wrapper" phx-update="ignore">
        <div id="canvas" phx-hook="Draw"></div>
      </div>

      <div class="mt-5 w-[384px] flex justify-between">
        <.button phx-click="reset" class="bg-red-400">Reset</.button>
        <.button phx-click="predict" class="bg-blue-400	">Predict</.button>
      </div>

      <%= if @prediction do %>
        <div class="mt-5">
          <div>
            Prediction: <%= @prediction %>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  def handle_event("reset", _params, socket) do
    {:noreply,
     socket
     |> assign(prediction: nil)
     |> push_event("reset", %{})}
  end

  def handle_event("predict", _params, socket) do
    {:noreply, push_event(socket, "predict", %{})}
  end

  def handle_event("image", "data:image/png;base64," <> raw, socket) do
    name = Base.url_encode64(:crypto.strong_rand_bytes(10), padding: false)
    path = Path.join(Application.app_dir(:digits, "priv"), "#{name}.png")

    File.write!(path, Base.decode64!(raw))

    prediction = Digits.Model.predict(path)

    File.rm!(path)

    {:noreply, assign(socket, prediction: prediction)}
  end
end
