defmodule Marites.AuditLog do
  use Ecto.Schema

  schema "audit_logs" do
    field :user_id,  :integer
    field :action,   :string
    field :ip,       :string
    field :vin,      :string
    field :result,   :string, default: "ok"
    field :metadata, :map

    timestamps(updated_at: false)
  end
end
