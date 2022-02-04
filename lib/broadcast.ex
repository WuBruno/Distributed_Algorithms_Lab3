# distributed algorithms, n.dulay, 10 jan 22
# lab3 - broadcast algorithms

defmodule Broadcast do
  def start do
    config = Helper.node_init()
    start(config, config.start_function)
  end

  # start/0

  defp start(_, :cluster_wait), do: :skip

  defp start(config, :cluster_start) do
    IO.puts("--> Broadcast at #{Helper.node_string()}")

    peers =
      for n <- 0..(config.n_peers - 1),
          into: %{},
          do: {n, Node.spawn(:"peer#{n}_#{config.node_suffix}", Peer, :start, [])}

    # Wait before starting the clients
    Process.sleep(500)

    # Bind
    for {id, pid} <- peers, do: send(pid, {:bind, id, peers})

    # Wait for bind
    Process.sleep(500)

    max_broadcasts = 3000
    timeout = 3000

    # Start
    for {_, pid} <- peers, do: send(pid, {:broadcast, max_broadcasts, timeout})
  end

  # start/2
end

# Broadcast
