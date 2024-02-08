defmodule XpamTest.Email.Headers.CollectorTest do
  use ExUnit.Case

  alias Email.Headers.Collector
  alias Email.Headers.Header

  @moduletag capture_log: true

  defp mock_html_headers(ctx) do
    filename = "some_email.eml"
    email_content = "To: <yyyy@neteze.com>
            Cc: <yyyy@netnoteinc.com>, <yyyy@netdoktor.dk>, <yyyy@netmagic.net>
            From: \"Rob\" <yelanotyami912@bot.or.th>
            Subject: hurry
            Date: Tue, 03 Dec 2002 08:54:07 -1700

            some content..."

    File.write!(filename, email_content, [:utf8, :binary])

    Map.merge(ctx, %{path: filename})
  end

  defp init_device(ctx) do
    {:ok, dev} = File.open(ctx[:path])

    Map.merge(ctx, %{device: dev})
  end

  defp free_resources(ctx) do
    # asynchronously close and remove file
    on_exit(fn ->
      t = Task.async(fn -> File.close(ctx[:device]) end)
      :ok = Task.await(t)
      File.rm!(ctx[:path])
    end)

    ctx
  end

  setup_all [:mock_html_headers, :init_device, :free_resources]

  describe "get/2" do
    test "get header successfully", %{device: dev} do
      header = "To"

      assert %Header{key: key, value: val} = Collector.get(dev, header)
      assert key == String.downcase(header)
      assert is_binary(val)
    end

    test "file descriptor should carry to beginning of file after collect", %{device: dev} do
      header = "Subject"

      %Header{key: key, value: _val} = Collector.get(dev, header)
      assert key == String.downcase(header)

      # read a header above the first one should prove that fd returns to BOF
      above = "To"
      assert %Header{key: key, value: _val} = Collector.get(dev, above)
      assert key == String.downcase(above)
    end

    test "get header for any casing", %{device: dev} do
      # Up-cased header
      upcased = "FROM"
      refute match?({:error, _}, Collector.get(dev, upcased))

      # Down-cased header
      downcased = "from"
      refute match?({:error, _}, Collector.get(dev, downcased))

      # Mixed-cased header
      mixedcased = "FroM"
      refute match?({:error, _}, Collector.get(dev, mixedcased))
    end

    test "nil header should get the current state", %{device: dev} do
      # set state
      header = "To"
      assert header = Collector.get(dev, header)

      # try get a nil header, should return the previous
      assert header == Collector.get(dev, nil)
    end

    test "should return error on non-existing header", %{device: dev} do
      non_existing = "Content-Type"

      assert {:error, reason} = Collector.get(dev, non_existing)
      assert is_atom(reason) and reason == :header_not_found
    end

    test "should not modify collected header when requested does not exist", %{device: dev} do
      # get existing header to keep it in the state
      existing = "Cc"
      header = Collector.get(dev, existing)

      refute match?({:error, _}, header)

      # try seek for a non-existing header
      non_existing = "Content-Type"
      assert {:error, _} = Collector.get(dev, non_existing)

      # state should be the same
      assert header == Collector.get(dev, nil)
    end

    #   test "should return key-value pair on multiple delimiters", ctx do
    #   end
  end
end
