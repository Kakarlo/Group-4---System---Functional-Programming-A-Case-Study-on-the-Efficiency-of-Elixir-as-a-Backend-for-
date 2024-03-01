defmodule Catalog.Author do
  use Ecto.Schema
  import Ecto.{Changeset, Query}
  alias Catalog.{Entry, Author, EntryAuthor, Repo}

  schema "author" do
    field :name, :string
    many_to_many :entry, Entry, join_through: EntryAuthor
  end

  def changeset(author, params \\ %{}) do
    author
    |> cast(params, [:name])
    |> validate_required([:name])
    |> unique_constraint([:name])
  end

  def add_author(name) do
    %Author{}
    |> Author.changeset(name)
    |> Repo.insert()
    IO.puts("Author Added Successfully")
  end

  def update_author(id, new) do
    a = Author
    |> Repo.get(id)
    Author.changeset(a, %{name: new})
    |> Repo.update()
  end

  def delete_author(id) do
    Repo.get(Author, id)
    |> Repo.delete()
  end

  def search_author(choice, input) do
    case choice do
      :name ->
        Author
        |> Repo.get_by(name: input)
      :id ->
        Author
        |> Repo.get(input)
    end
  end

  def show_author(choice, input) do
    author = search_author(choice, input)
    unless author == nil do
      header()
      author
      |> print_author()
      author.id
    else
      IO.puts("No entry has been found")
    end
  end

  def show_all do
    header()
    from(a in Author, order_by: a.id)
    |> Repo.all()
    |> Enum.each(&print_author/1)
  end

  defp print_author(struct) do
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
