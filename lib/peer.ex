# distributed algorithms, n.dulay, 10 jan 22
# basic flooding, v1

defmodule Peer do
  # add your code here, start(), next() and any other functions
  def start(id, broadcast_pid) do
    # IO.puts("-> Starting Peer at #{Helper.node_string()}")

    # Initialise PL
    pl = spawn(PL, :start, [id])
    # Initialise Client
    client = spawn(Client, :start, [id])
    # Initialise BEB
    beb = spawn(BEB, :start, [id])

    send(broadcast_pid, {:pl_start, id, pl})

    receive do
      {:bind, peers} ->
        send(client, {:bind, pl, beb, Map.keys(peers)})
        send(pl, {:bind, client, peers})
        send(beb, {:bind, pl, client, Map.keys(peers)})
        # IO.puts("Peer#{id} initialised")
    end
  end
end
