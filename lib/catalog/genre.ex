defmodule Catalog.Genre do
  use Ecto.Schema
  import Ecto.{Changeset, Query}
  alias Catalog.{Entry, Genre, EntryGenre, Repo}

  schema "Genre" do
    field :name, :string
    many_to_many :entry, Entry, join_through: EntryGenre
  end

  def changeset(genre, params \\ %{}) do
    genre
    |> cast(params, [:name])
    |> validate_required([:name])
    |> unique_constraint([:name])
  end

  def add_genre(name) do
    %Genre{}
    |> Genre.changeset(name)
    |> Repo.insert()
    IO.puts("Genre Added Successfully")
  end

  def update_genre(id, new) do
    g = Genre
    |> Repo.get(id)
    Genre.changeset(g, %{name: new})
    |> Repo.update()
  end

  def delete_genre(id) do
    Repo.get(Genre, id)
    |> Repo.delete()
  end

  def search_genre(choice, input) do
    case choice do
      :name ->
        Genre
        |> Repo.get_by(name: input)
      :id ->
        Genre
        |> Repo.get(input)
    end
  end

  def show_genre(choice, input) do
    genre = search_genre(choice, input)
    unless genre == nil do
      header()
      genre
      |> Repo.preload(:entry)
      |> print_genre_entry()
      genre.id
    else
      IO.puts("No entry has been found")
    end
  end

  def show_all do
    header()
    from(g in Genre, order_by: g.id)
    |> Repo.all()
    |> Enum.each(&print_genre/1)
  end

  defp print_genre(struct) do
    IO.puts("| #{pad(struct.id |> Integer.to_string(), 6)} | #{pad(struct.name, 10)} |")
  end

  defp print_genre_entry(struct) do
    en = struct.entry
    entry = Enum.map(en, fn x -> "| #{pad(x.id |> Integer.to_string(), 6)} | #{pad(x.name, 20)} | "end) |> Enum.join("\n")
    IO.puts("| #{pad(struct.id |> Integer.to_string(), 6)} | #{pad(struct.name, 10)} |\n\nWorks Incl. #{struct.name}:\n#{entry}")
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
