defmodule Catalog.Repo.Migrations.CreateEntryGenre do
  use Ecto.Migration

  def change do
    create table(:entry_genre, primary_key: false) do
      add :entry_id, references(:entry, on_delete: :delete_all), primary_key: true
      add :genre_id, references(:genre, on_delete: :delete_all), primary_key: true

      timestamps(default: fragment("now()"))
    end
  end
end
