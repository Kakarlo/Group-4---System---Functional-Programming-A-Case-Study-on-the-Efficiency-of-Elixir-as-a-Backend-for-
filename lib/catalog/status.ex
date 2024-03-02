defmodule Catalog.Status do
  use Ecto.Schema
  import Ecto.{Changeset, Query}
  alias Catalog.{Entry, Status, Repo}

  schema "status" do
    field :name, :string
    has_many :entry, Entry
  end

  def changeset(status, params \\ %{}) do
    status
    |> cast(params, [:name])
    |> validate_required([:name])
    |> unique_constraint([:name])
  end

  def check_status(id) do
    query = from s in Status,
    where: s.id == ^id
    Repo.exists?(query)
  end

  def exist_status(id) do
    query = from e in Entry,
    where: e.status_id == ^id
    Repo.exists?(query)
  end

  def add_status(name) do
    %Status{}
    |> Status.changeset(name)
    |> Repo.insert()
    IO.puts("Status Added Successfully")
  end

  def update_status(id, new) do
    s = Status
    |> Repo.get(id)
    Status.changeset(s, %{name: new})
    |> Repo.update()
  end

  def delete_status(id) do
    Repo.get(Status, id)
    |> Repo.delete()
  end

  def search_status(choice, input) do
    case choice do
      :name ->
        Status
        |> Repo.get_by(name: input)
      :id ->
        Status
        |> Repo.get(input)
    end
  end

  def show_status(choice, input) do
    status = search_status(choice, input)
    unless status == nil do
      header()
      status
      |> print_status()
      status.id
    else
      IO.puts("No entry has been found")
    end
  end

  def show_all do
    header()
    from(s in Status, order_by: s.id)
    |> Repo.all()
    |> Enum.each(&print_status/1)
  end

  defp print_status(struct) do
    IO.puts("| #{pad(struct.id |> Integer.to_string(), 6)} | #{pad(struct.name, 10)} |")
  end

  defp pad(input, pad) do
    String.split(input)
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
    |> String.pad_trailing(pad)
  end

  defp header do
    IO.puts("| #{pad("ID", 6)} | #{pad("Name", 10)} |\n")
  end
end
