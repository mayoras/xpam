defmodule XpamTest.Email.ReaderTest do
  use ExUnit.Case, async: true

  import Xpam.Email.Reader

  describe "open_file/1" do
    setup do
      filename = "some_email.eml"
      email_content = "<h1>email content</h1>"
      File.write!(filename, email_content, [:utf8, :binary])
      on_exit(fn -> File.rm!(filename) end)

      {:ok, path: filename, content: email_content}
    end

    test "should open file successfully", context do
      path = context[:path]
      content = context[:content]

      case open_file(path) do
        {:ok, io} ->
          assert is_pid(io)
          assert File.read!(path) == content

        {:error, reason} ->
          flunk("File should have opened successfully: #{reason}")
      end
    end

    test "path should be a string" do
      invalid_path = 33

      assert_raise FunctionClauseError, fn -> open_file(invalid_path) end
    end

    test "should not open file for non-existing path" do
      nonexisting_path = "do_not_exist.txt"

      case open_file(nonexisting_path) do
        {:ok, _} ->
          flunk("Should not open a non-existing path")

        {:error, reason} ->
          # :eexist posix error should be the reason why it failed
          assert String.contains?(reason, inspect(:enoent))
      end
    end
  end
end
