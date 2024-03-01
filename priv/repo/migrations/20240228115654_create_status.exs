defmodule Catalog.Repo.Migrations.CreateStatus do
  use Ecto.Migration

  def change do
    create table(:status) do
      add :name, :string
    end

    create unique_index(:status, [:name])
  end
end
