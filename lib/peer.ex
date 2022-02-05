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

    send(broadcast_pid, {:pl_start, id, pl})

    receive do
      {:bind, peers} ->
        send(client, {:bind, pl, beb, Map.keys(peers)})
        send(pl, {:bind, client, peers})
        send(beb, {:bind, pl, client, Map.keys(peers)})

        if id in faulty_pids do
          Process.send_after(self(), {:exit}, faulty_time)
          await_fault(id, client, pl, beb)
        end

        # IO.puts("Peer#{id} initialised")
    end
  end

  defp await_fault(id, client, pl, beb) do
    receive do
      {:exit} ->
        Process.exit(client, "Peer#{id} Client exit")
        Process.exit(pl, "Peer#{id} PL exit")
        Process.exit(beb, "Peer#{id} BEB exit")
        Process.exit(self(), "Peer#{id} exit")
    end
  end
end
