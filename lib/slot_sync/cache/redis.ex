defmodule SlotSync.Cache.Redis do
  @moduledoc """
  A interface for caching shift data into redis
  """
  use GenServer

  use Confex, otp_app: :slot_sync

  @key_prefix "slot:"

  @spec start_link() :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link, do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  def get(shift), do: GenServer.call(__MODULE__, {:get, shift})
  def set(shift), do: GenServer.cast(__MODULE__, {:set, shift})
  def del(shift), do: GenServer.cast(__MODULE__, {:del, shift})
  def del_all, do: GenServer.cast(__MODULE__, {:del_all})

  # Callbacks

  @impl true
  @spec init(any()) :: {:ok, pid()}
  def init(_) do
    {:ok, conn} = Redix.start_link(redis_host(), name: :slot_sync)
    {:ok, conn}
  end

  @impl true
  def handle_call({:get, shift}, _caller, conn) do
    {:ok, shift} = Redix.command(conn, ["GET", key(shift)])

    {:reply, decode(shift), conn}
  end

  @impl true
  def handle_cast({:set, shift}, conn) do
    {:ok, _shift} =
      Redix.command(conn, ["SETEX", key(shift), expire_cache(), shift |> Poison.encode!()])

    {:noreply, conn}
  end

  @impl true
  def handle_cast({:del, shift}, conn) do
    {:ok, _shift} = Redix.command(conn, ["DEL", key(shift)])

    {:noreply, conn}
  end

  @impl true
  def handle_cast({:del_all}, conn) do
    {:ok, slots} = Redix.command(conn, ["KEYS", @key_prefix <> "*"])
    slots |> Enum.map(fn slot -> Redix.command(conn, ["DEL", slot]) end)

    {:noreply, conn}
  end

  defp decode(nil), do: nil
  defp decode(shift), do: shift |> Poison.decode!()

  defp key(shift), do: @key_prefix <> shift_id(shift)
  defp shift_id(shift), do: Integer.to_string(shift["id"])

  defp redis_host, do: config()[:redis_host]
  defp expire_cache, do: config()[:expire_cache]
end
