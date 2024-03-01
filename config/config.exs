import Config

config :catalog, ecto_repos: [Catalog.Repo]
config :catalog, Catalog.Repo,
  database: "db_test_pl",
  username: "root",
  password: "",
  hostname: "localhost",
  port: 3306,
  log: false
