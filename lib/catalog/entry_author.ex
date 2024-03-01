defmodule Catalog.EntryAuthor do
  use Ecto.Schema
  alias Catalog.{Entry, Author}

  @primary_key false
  schema "entry_author" do
    belongs_to :entry, Entry
    belongs_to :author, Author

    timestamps()
  end
end
