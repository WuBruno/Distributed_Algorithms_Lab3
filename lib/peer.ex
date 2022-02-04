# distributed algorithms, n.dulay, 10 jan 22
# basic flooding, v1

defmodule Peer do
  # add your code here, start(), next() and any other functions
  def start do
    IO.puts("-> Starting Peer at #{Helper.node_string()}")

    receive do
      {:bind, id, peers} -> next(id, peers)
    end
  end

  defp next(id, peers) do
    receive do
      {:broadcast, max_broadcasts, timeout} ->
        for {_, pid} <- peers, do: send(pid, {:max_broadcasts, id})
        IO.puts("Peer#{id} received and started max_broadcast")

        send_count = for {peer_id, _} <- peers, into: %{}, do: {peer_id, 1}
        receive_count = for {peer_id, _} <- peers, into: %{}, do: {peer_id, 0}

        Process.send_after(self(), {:timeout}, timeout)
        next(id, peers, max_broadcasts, timeout, send_count, receive_count)
    end
  end

  defp next(id, peers, max_broadcasts, timeout, send_count, receive_count) do
    receive do
      {:timeout} ->
        output =
          for {_k, [s, r]} <- Map.merge(send_count, receive_count, fn _k, s, r -> [s, r] end),
              into: "",
              do: "{#{s}, #{r}}  "

        IO.puts("Peer#{id}  " <> output)

      {:max_broadcasts, sender_id} ->
        # Increment receive
        receive_count = Map.update!(receive_count, sender_id, fn val -> val + 1 end)

        # Increment send count
        send_count =
          if send_count[sender_id] < max_broadcasts do
            # Send
            send(peers[sender_id], {:max_broadcasts, id})
            # IO.puts("Peer#{id} sending to #{sender_id} #{send_count[sender_id]}")

            # Increment send
            Map.update!(send_count, sender_id, fn val -> val + 1 end)
          else
            send_count
          end

        next(id, peers, max_broadcasts, timeout, send_count, receive_count)
    end
  end
end

# Peer
