# distributed algorithms, n.dulay, 10 jan 22
# basic flooding, v1

defmodule Peer do
  # add your code here, start(), next() and any other functions
  def start(id, broadcast_pid, reliability, faulty_pids, faulty_time) do
    # IO.puts("-> Starting Peer at #{Helper.node_string()}")

    # Initialise PL
    pl = spawn(LPL, :start, [id, reliability])
    # Initialise Client
    client = spawn(Client, :start, [id])
    # Initialise BEB
    beb = spawn(BEB, :start, [id])
    # Initialise ERB
    erb = spawn(ERB, :start, [id])

    send(broadcast_pid, {:pl_connect, id, pl})

    receive do
      {:bind, peers} ->
        peer_ids = Map.keys(peers)
        send(pl, {:bind, beb, peers})
        send(beb, {:bind, pl, erb, peer_ids})
        send(erb, {:bind, beb, client})
        send(client, {:bind, erb, peer_ids})

        # Initialise faulty pids if applicable
        if id in faulty_pids do
          Process.send_after(self(), {:exit}, faulty_time)
          await_fault(id, client, pl, beb, erb)
        end

        # IO.puts("Peer#{id} initialised")
    end
  end

  defp await_fault(id, client, pl, beb, erb) do
    receive do
      {:exit} ->
        Process.exit(client, "Peer#{id} Client exit")
        Process.exit(pl, "Peer#{id} PL exit")
        Process.exit(beb, "Peer#{id} BEB exit")
        Process.exit(erb, "Peer#{id} ERB exit")
        Process.exit(self(), "Peer#{id} exit")
    end
  end
end
