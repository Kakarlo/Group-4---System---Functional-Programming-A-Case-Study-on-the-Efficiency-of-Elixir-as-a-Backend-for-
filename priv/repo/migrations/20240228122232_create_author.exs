defmodule Catalog.Repo.Migrations.CreateAuthor do
  use Ecto.Migration

  def change do
    create table(:author) do
      add :name, :string
    end

    create unique_index(:author, [:name])
  end
end
