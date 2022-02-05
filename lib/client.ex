defmodule Client do
  def start(id) do
    receive do
      {:bind, pl_pid, peer_ids} ->
        # IO.puts("Client#{id} initialised #{inspect(pl_pid)} #{inspect(peer_ids)}")
        next(id, pl_pid, peer_ids)
    end
  end

  defp next(id, pl_pid, peer_ids) do
    receive do
      {:pl_deliver, _sender_id, payload} ->
        case payload do
          {:broadcast, max_broadcasts, timeout} ->
            # Begin max_broadcasts
            for peer_id <- peer_ids,
                do: send(pl_pid, {:pl_send, peer_id, {:max_broadcasts}})

            IO.puts("Peer#{id} received and started max_broadcast")

            send_count = for peer_id <- peer_ids, into: %{}, do: {peer_id, 1}
            receive_count = for peer_id <- peer_ids, into: %{}, do: {peer_id, 0}

            Process.send_after(pl_pid, {:pl_send, id, {:timeout}}, timeout)

            max_broadcast(
              id,
              pl_pid,
              peer_ids,
              max_broadcasts,
              timeout,
              send_count,
              receive_count
            )
        end
    end
  end

  defp max_broadcast(
         id,
         pl_pid,
         peer_ids,
         max_broadcasts,
         timeout,
         send_count,
         receive_count
       ) do
    receive do
      {:pl_deliver, sender_id, payload} ->
        case payload do
          {:timeout} ->
            output =
              for {_k, [s, r]} <- Map.merge(send_count, receive_count, fn _k, s, r -> [s, r] end),
                  into: "",
                  do: "{#{s}, #{r}}  "

            IO.puts("Peer#{id}:  " <> output)

          {:max_broadcasts} ->
            # Increment receive
            receive_count = Map.update!(receive_count, sender_id, fn val -> val + 1 end)

            # Increment send count
            send_count =
              if send_count[sender_id] < max_broadcasts do
                # Send
                send(pl_pid, {:pl_send, sender_id, {:max_broadcasts}})

                # Increment send
                Map.update!(send_count, sender_id, fn val -> val + 1 end)
              else
                send_count
              end

            max_broadcast(
              id,
              pl_pid,
              peer_ids,
              max_broadcasts,
              timeout,
              send_count,
              receive_count
            )
        end
    end
  end
end

# Client
