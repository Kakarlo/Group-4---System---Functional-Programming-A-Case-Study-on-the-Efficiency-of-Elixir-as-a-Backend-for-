defmodule Catalog.EntryGenre do
  use Ecto.Schema
  alias Catalog.{Entry, Genre}

  @primary_key false
  schema "entry_genre" do
    belongs_to :entry, Entry
    belongs_to :genre, Genre

    timestamps()
  end
end
