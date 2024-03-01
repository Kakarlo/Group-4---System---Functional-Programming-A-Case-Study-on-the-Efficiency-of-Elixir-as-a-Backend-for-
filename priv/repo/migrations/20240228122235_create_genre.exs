defmodule Catalog.Repo.Migrations.CreateGenre do
  use Ecto.Migration

  def change do
    create table(:genre) do
      add :name, :string
    end

    create unique_index(:genre, [:name])
  end
end
