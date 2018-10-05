defmodule SlotSync.Cache.Redis do
  use GenServer

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
    {:ok, conn} = Redix.start_link("redis://localhost:6379/3", name: :redix)
    {:ok, conn}
  end

  @impl true
  def handle_call({:get, shift}, _caller, conn) do
    {:ok, shift} = Redix.command(conn, ["GET", shift["id"]])

    {:reply, decode(shift), conn}
  end

  @impl true
  def handle_cast({:set, shift}, conn) do
    {:ok, _shift} = Redix.command(conn, ["SET", shift["id"], shift |> Poison.encode!()])

    {:noreply, conn}
  end

  @impl true
  def handle_cast({:del, shift}, conn) do
    {:ok, _shift} = Redix.command(conn, ["DEL", shift["id"]])

    {:noreply, conn}
  end

  @impl true
  def handle_cast({:del_all}, conn) do
    # {:ok, _shift} = Redix.command(conn, ["SET", shift["id"], shift |> Poison.encode!()])

    {:noreply, conn}
  end

  defp decode(nil), do: nil
  defp decode(shift), do: shift |> Poison.decode!()
end
