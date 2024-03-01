defmodule Catalog.Repo.Migrations.CreateEntry do
  use Ecto.Migration

  def change do
    create table(:entry) do
      add :name, :string
      add :status_id, references(:status, on_delete: :nilify_all)

      timestamps(default: fragment("now()"))
    end

    create unique_index(:entry, [:name])
  end
end
