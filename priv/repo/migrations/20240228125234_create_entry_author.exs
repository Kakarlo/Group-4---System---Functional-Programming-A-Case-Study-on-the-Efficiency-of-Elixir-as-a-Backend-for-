defmodule Catalog.Repo.Migrations.CreateEntryAuthor do
  use Ecto.Migration

  def change do
    create table(:entry_author, primary_key: false) do
      add :entry_id, references(:entry, on_delete: :delete_all), primary_key: true
      add :author_id, references(:author, on_delete: :delete_all), primary_key: true

      timestamps(default: fragment("now()"))
    end
  end
end
