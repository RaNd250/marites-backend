defmodule Marites.Log.Car do
  use Ecto.Schema
  import Ecto.Changeset

  alias Marites.Log.{ChargingProcess, Position, Drive}
  alias Marites.Settings.CarSettings

  schema "cars" do
    field :name,           :string
    field :efficiency,     :float
    field :model,          :string
    field :trim_badging,   :string
    field :marketing_name, :string

    field :eid, :integer
    field :vid, :integer
    field :vin, :string
    field :user_id, :integer
    field :display_priority, :integer

    belongs_to :settings, CarSettings

    has_many :charging_processes, ChargingProcess
    has_many :positions, Position
    has_many :drives, Drive

    timestamps()
  end

  @doc false
  def changeset(car, attrs) do
    car
    |> cast(attrs, [
      :eid,
      :vid,
      :vin,
      :name,
      :model,
      :efficiency,
      :trim_badging,
      :marketing_name,
      :display_priority
    ])
    |> validate_required([:eid, :vid, :vin])
    |> unique_constraint(:settings_id)
    |> unique_constraint(:eid)
    |> unique_constraint(:vin)
    |> unique_constraint(:vid)
  end
end
