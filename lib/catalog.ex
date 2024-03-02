defmodule Catalog do
  alias Catalog.{Entry, Author, Genre, Status, Repo}

  def run do
    main_menu()
  end

#------------------------------------ Command Line Design ------------------------------------------------------

  defp menu do
    IO.puts(
    "    _____________________________     \n" <>
    "   |                             |    \n" <>
    "   |          Main Menu          |    \n" <>
    "   |_____________________________|    \n" <>
    "    _____________________________     \n" <>
    "   |                             |    \n" <>
    "   | 1. Entry                    |    \n" <>
    "   | 2. Author                   |    \n" <>
    "   | 3. Genre                    |    \n" <>
    "   | 4. Status                   |    \n" <>
    "   | 0. Exit                     |    \n" <>
    "   |_____________________________|    \n"
    )
  end

  defp menu_2(choice) do
    IO.puts(
    "    _____________________________     \n" <>
    "   |                             |    \n" <>
    "   |          #{pad(choice, 6)}             |    \n" <>
    "   |_____________________________|    \n" <>
    "    _____________________________     \n" <>
    "   |                             |    \n" <>
    "   | 1. Add #{pad(choice, 6)}               |    \n" <>
    "   | 2. View All #{pad(choice, 6)}          |    \n" <>
    "   | 3. Search #{pad(choice, 6)} by Name    |    \n" <>
    "   | 4. Search #{pad(choice, 6)} by ID      |    \n" <>
    "   | 5. Update #{pad(choice, 6)} by Name    |    \n" <>
    "   | 6. Update #{pad(choice, 6)} by ID      |    \n" <>
    "   | 7. Remove #{pad(choice, 6)} by Name    |    \n" <>
    "   | 8. Remove #{pad(choice, 6)} by ID      |    \n" <>
    "   | 0. Back                     |    \n" <>
    "   |_____________________________|    \n"
    )
  end

  defp pad(input, pad) do
    String.pad_trailing(input, pad)
  end

#------------------------------------ Input Verification Functions ---------------------------------------------

  defp input_string(prompt) do
    input = IO.gets(prompt)
    |> String.trim()
    |> String.downcase()
    unless input == ":stop" do
      input
    else
      :stop
    end
  end

  defp input_name(prompt, schema) do
    name = input_string(prompt)
    case name do
      "" ->
        IO.puts("Name cannot not be null")
        input_name(prompt, schema)
      :stop -> name
      _ ->
        unless Repo.get_by(schema, name: name) == nil do
          IO.puts("Please Enter a Unique Name!")
          input_name(prompt, schema)
        else
          name
        end
    end
  end

  defp input_num(prompt) do
    num = input_string(prompt)
    unless num == :stop do
      numb = num |> Integer.parse()
      case numb do
        :error ->
          IO.puts("Please Enter a Valid Number!")
          input_num(prompt)
        {number, _} -> number
      end
    else
      :stop
    end
  end

  defp input_status(prompt) do
    status_id = input_num(prompt)
    unless status_id == :stop do
      if Status.check_status(status_id) do
        status_id
      else
        IO.puts("Please Enter a Valid Status ID!")
        input_status(prompt)
      end
    end
  end

  defp input_list(prompt) do
    list = input_string(prompt)
    unless list == :stop do
      list
      |> String.downcase()
      |> String.split(~r{,\s+})
      |> Enum.map(&String.trim/1)
      |> Enum.reject(& &1 == "")
      |> Enum.uniq()
    else
      :stop
    end

  end

#------------------------------------ Program Menu -------------------------------------------------------------

  defp main_menu do
    menu()
    choice = input_num("   : ")
    case {choice} do
      {1} -> main_menu2(:entry)
      {2} -> main_menu2(:author)
      {3} -> main_menu2(:genre)
      {4} -> main_menu2(:status)
      {0} ->
        IO.puts("Shutting Down. . .")
      {:stop} -> :ok
      _ ->
        IO.puts("Invalid Input")
        main_menu()
    end
  end

  defp main_menu2(type) do
    case type do
      :entry -> menu_2("Entry")
      :author -> menu_2("Author")
      :genre -> menu_2("Genre")
      :status -> menu_2("Status")
    end
    choice = input_num("   : ")
    case {choice} do
      {1} -> add_one(type)
      {2} -> view_all(type)
      {3} ->
        search_one(:name, type)
      {4} ->
        search_one(:id, type)
      {5} ->
        search(:name, type, :update)
      {6} ->
        search(:id, type, :update)
      {7} ->
        search(:name, type, :delete)
      {8} ->
        search(:id, type, :delete)
      {0} ->
      main_menu()
      {:stop} -> :ok
      _ ->
        IO.puts("Invalid Input")
        main_menu()
    end
  end

  defp entry_author(entry) do
    author = input_list("Author: ")
    unless author == :stop do
      entry_genre(Map.put_new(entry, :author, author))
    else
      main_menu2(:entry)
    end
  end

  defp entry_genre(entry) do
    genre = input_list("Genre: ")
    unless genre == :stop do
      entry_status(Map.put_new(entry, :genre, genre))
    else
      main_menu2(:entry)
    end
  end

  defp entry_status(entry) do
    Status.show_all()
    status = input_status("Status ID: ")
    unless status == :stop do
      params = Map.put_new(entry, :status_id, status)
      Entry.add_entry(params)
      Entry.show_entry(:name, entry.name)
      IO.gets("Press Enter to proceed")
      main_menu2(:entry)
    else
      main_menu2(:entry)
    end
  end

  defp view_all(type) do
    case type do
      :entry ->
        Entry.show_all()
      :author ->
        Author.show_all()
      :genre ->
        Genre.show_all()
      :status ->
        Status.show_all()
    end
    IO.gets("Press Enter to proceed")
    main_menu2(type)
  end

  defp name_or_id(choice) do
    case choice do
      :name -> input_string("Enter the Name: ")
      :id -> input_num("Enter the ID: ")
    end
  end

  defp add_one(type) do
    case type do
      :entry ->
        name = input_name("Enter Entry Name: ", Entry)
        unless name == :stop do
          entry_author(%{name: name})
        end
      :author ->
        name = input_name("Enter Author Name: ", Author)
        unless name == :stop do
          Author.add_author(%{name: name})
          IO.gets("Press Enter to Proceed")
        else
        end
      :genre ->
        name = input_name("Enter Genre Name: ", Genre)
        unless name == :stop do
          Genre.add_genre(%{name: name})
          IO.gets("Press Enter to Proceed")
        else
        end
      :status ->
        name = input_name("Enter Status Name: ", Status)
        unless name == :stop do
          Status.add_status(%{name: name})
          IO.gets("Press Enter to Proceed")
        else
        end
    end
    main_menu2(type)
  end

  defp search_one(choice, type) do
    input = name_or_id(choice)
    unless input == :stop do
      case type do
        :entry ->
          Entry.show_entry(choice, input)
        :author ->
          Author.show_author(choice, input)
        :genre ->
          Genre.show_genre(choice, input)
        :status ->
          Status.show_status(choice, input)
      end
      IO.gets("Press Enter to proceed")
      main_menu2(type)
    else
      main_menu2(type)
    end
  end

  defp search(choice, type, action) do
    input = name_or_id(choice)
    unless input == :stop do
      case type do
        :entry ->
          id = Entry.show_entry(choice, input)
          search_action(id, type, action)
        :author ->
          id = Author.show_author(choice, input)
          search_action(id, type, action)
        :genre ->
          id = Genre.show_genre(choice, input)
          search_action(id, type, action)
        :status ->
          id = Status.show_status(choice, input)
          search_action(id, type, action)
      end
    else
      main_menu2(type)
    end
  end

  defp search_action(id, type, action) do
    unless id == :ok do
      case action do
        :update -> update_one(id, type)
        :delete -> remove_one(id, type)
      end
    else
      IO.gets("Press Enter to proceed")
      main_menu2(type)
    end
  end


  defp update_entry(_id, _attr, :stop) do main_menu2(:entry)
  end

  defp update_entry(id, attr, input) do
    case attr do
      :name ->
        Entry.update_entry(id, input, :name)
      :author ->
        Entry.update_entry_author(id, input)
      :genre ->
        Entry.update_entry_genre(id, input)
      :status ->
        Entry.update_entry(id, input, :status_id)
    end
    Entry.show_entry(:id, id)
    IO.puts("Update Successful!")
    IO.gets("Press Enter to proceed")
    main_menu2(:entry)
  end

  defp update_one(id, type) do
    case type do
      :entry ->
        IO.puts("| 1. ID  | 2. Author | 3. Genre | 4. Status |")
        input = input_num("Enter Choice : ")
        unless input == :stop do
          case input do
            1 ->
              new = input_name("Enter the New Name: ", Entry)
              update_entry(id, :name, new)
            2 ->
              new = input_list("Enter the New Author: ")
              update_entry(id, :author, new)
            3 ->
              new = input_list("Enter the New Genre: ")
              update_entry(id, :genre, new)
            4 ->
              new = input_num("Enter New Status ID: ")
              update_entry(id, :status, new)
            _ ->
              IO.puts("Invalid Choice!")
          end
        else
          :stop
        end
      :author ->
        new = input_name("Enter New Author Name: ", Author)
        unless new == :stop do
          Author.update_author(id, new)
          Author.show_author(:id, id)
          IO.puts("Author has Been Updated Successfully!")
        end
      :genre ->
        new = input_name("Enter New Genre Name: ", Genre)
        unless new == :stop do
          Genre.update_genre(id, new)
          Genre.show_genre(:id, id)
          IO.puts("Genre has Been Updated Successfully!")
        end
      :status ->
        new = input_name("Enter New Genre Name: ", Status)
        unless new == :stop do
          Status.update_status(id, new)
          Status.show_status(:id, id)
          IO.puts("Status has Been Updated Successfully!")
        end
    end
    IO.gets("Press Enter to proceed")
    main_menu2(type)
  end

  defp remove_one(id, type) do
    confirmation = input_string("Are you sure with this action?\nDeleted files will be gone forever (y): ")
    case confirmation do
      "y" ->
        case type do
          :entry ->
            Entry.delete_entry(id)
            IO.puts("Entry has been deleted")
          :author ->
            Author.delete_author(id)
            IO.puts("Author has been deleted")
          :genre ->
            Genre.delete_genre(id)
            IO.puts("Genre has been deleted")
          :status ->
            unless Status.exist_status(id) do
              Status.delete_status(id)
              IO.puts("Status has been deleted")
            else
              IO.puts("Status must not be present in any Entry to continue deletion!")
            end
        end
        IO.gets("Press Enter to proceed")
        main_menu2(type)
      _ ->
        IO.puts("Action has failed!")
        IO.gets("Press Enter to proceed")
        main_menu2(type)
    end
  end

end
