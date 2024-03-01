defmodule Catalog.Entry do
  use Ecto.Schema
  import Ecto.{Changeset, Query}
  alias Catalog.{Entry, Author, Genre, Status, EntryAuthor, EntryGenre, Repo}

  schema "entry" do
    field :name, :string
    belongs_to :status, Status
    many_to_many :author, Author, join_through: EntryAuthor, on_replace: :delete
    many_to_many :genre, Genre, join_through: EntryGenre, on_replace: :delete

    timestamps()
  end

  def changeset(entry, params \\ %{}) do
    entry
    |> cast(params, [:name, :status_id])
    |> validate_required([:name, :status_id])
    |> unique_constraint([:name])
    |> put_assoc(:author, parse_author(params, :author))
    |> put_assoc(:genre, parse_genre(params, :genre))
  end

  def author_changeset(entry, params \\ %{}) do
    entry
    |> cast(params, [:name, :status_id])
    |> validate_required([:name, :status_id])
    |> unique_constraint([:name])
    |> put_assoc(:author, parse_author(params, :author))
  end

  def genre_changeset(entry, params \\ %{}) do
    entry
    |> cast(params, [:name, :status_id])
    |> validate_required([:name, :status_id])
    |> unique_constraint([:name])
    |> put_assoc(:genre, parse_genre(params, :genre))
  end

  def update_changeset(entry, params \\ %{}) do
    entry
    |> cast(params, [:name, :status_id])
    |> validate_required([:name, :status_id])
    |> unique_constraint([:name])
  end

  defp parse_author(params, type) do
    (params[type] || "")
    |> Enum.map(&get_or_insert_author/1)
  end

  defp get_or_insert_author(name) do
    Repo.get_by(Author, name: name) ||
      Repo.insert!(%Author{name: name})
  end

  defp parse_genre(params, type) do
    (params[type] || "")
    |> Enum.map(&get_or_insert_genre/1)
  end

  defp get_or_insert_genre(name) do
    Repo.get_by(Genre, name: name) ||
      Repo.insert!(%Genre{name: name})
  end

  def add_entry(params \\ %{}) do
    %Entry{}
    |> Entry.changeset(params)
    |> Repo.insert()
    IO.puts("Entry Added Successfully")
  end

  def search_entry(choice, input) do
    case choice do
      :name ->
        Entry
        |> Repo.get_by(name: input)
      :id ->
        Entry
        |> Repo.get(input)
    end
  end

  def show_entry(choice, input) do
    entry = search_entry(choice, input)
    unless entry == nil do
      header()
      entry
      |> Repo.preload([:author, :genre, :status])
      |> print_entry()
      entry.id
    else
      IO.puts("No entry has been found")
    end
  end

  def show_all do
    header()
    from(e in Entry, order_by: e.id)
    |> Repo.all()
    |> Repo.preload([:author, :genre, :status])
    |> Enum.each(&print_entry/1)
  end

  def update_entry_author(id, input) do
    e = Entry
    |> Repo.get(id)
    |> Repo.preload([:author])
    Entry.author_changeset(e, %{author: input})
    |> Repo.update()
  end

  def update_entry_genre(id, input) do
    e = Entry
    |> Repo.get(id)
    |> Repo.preload([:genre])
    Entry.genre_changeset(e, %{genre: input})
    |> Repo.update()
  end

  def update_entry(id, input, attr) do
    e = Entry
    |> Repo.get(id)
    Entry.update_changeset(e, %{attr => input})
    |> Repo.update()
  end

  def delete_entry(id) do
    Repo.get(Entry, id)
    |> Repo.delete()
  end

  defp print_entry(struct) do
    au = struct.author
    author = Enum.map(au, fn x -> x.name end) |> Enum.join(", ")
    ge = struct.genre
    genre = Enum.map(ge, fn x -> x.name end) |> Enum.join(", ")
    IO.puts("| #{pad(struct.id |> Integer.to_string(), 6)} | #{pad(struct.name, 20)} | #{pad(author, 20)} | #{pad(genre, 20)} | #{pad(struct.status.name, 10)} | ")
  end

  defp header do
    IO.puts("| #{pad("ID", 6)} | #{pad("Entry Name", 20)} | #{pad("Author", 20)} | #{pad("Genre", 20)} | #{pad("Status", 10)} | \n")
  end

  defp pad(input, pad) do
    String.split(input)
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
    |> String.pad_trailing(pad)
  end

end
