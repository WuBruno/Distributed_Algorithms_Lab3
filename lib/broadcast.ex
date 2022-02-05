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

    peer_pids =
      for n <- 0..(config.n_peers - 1),
          into: %{},
          do: {n, Node.spawn(:"peer#{n}_#{config.node_suffix}", Peer, :start, [n, self()])}

    # Bind PLs
    peer_pls = receive_pls(peer_pids, %{})

    IO.puts("Everything set up and start broadcast")

    max_broadcasts = 3000
    timeout = 3000

    # Start
    for {_, peer_pl} <- peer_pls,
        do:
          send(
            peer_pl,
            {:deliver, -1, {:broadcast, max_broadcasts, timeout}}
          )
  end

  defp receive_pls(peer_pids, peer_pls) do
    receive do
      {:pl_start, id, pl} ->
        peer_pls = Map.put_new(peer_pls, id, pl)

        if map_size(peer_pls) == map_size(peer_pids) do
          # Once all received broadcast
          for {_k, peer_pid} <- peer_pids, do: send(peer_pid, {:bind, peer_pls})
          # Return peer_pls
          peer_pls
        else
          # Otherwise continue receiving
          receive_pls(peer_pids, peer_pls)
        end
    end
  end

  # start/2
end

# Broadcast
