defmodule Client do
  def start(id) do
    receive do
      {:bind, pl, beb, peer_ids} ->
        # IO.puts("Client#{id} initialised #{inspect(pl)} #{inspect(peer_ids)}")
        next(id, pl, beb, peer_ids)
    end
  end

  defp next(id, pl, beb, peer_ids) do
    receive do
      {:pl_deliver, _sender_id, payload} ->
        case payload do
          {:broadcast, max_broadcasts, timeout} ->
            # Begin max_broadcasts
            send(beb, {:beb_broadcast, {:max_broadcast}})

            IO.puts("Peer#{id} received and started max_broadcast")

            send_count = for peer_id <- peer_ids, into: %{}, do: {peer_id, 1}
            receive_count = for peer_id <- peer_ids, into: %{}, do: {peer_id, 0}

            Process.send_after(pl, {:pl_send, id, {:timeout}}, timeout)

            max_broadcast(
              id,
              pl,
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
         pl,
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

          {:max_broadcast} ->
            # Increment receive
            receive_count = Map.update!(receive_count, sender_id, fn val -> val + 1 end)

            # Increment send count
            send_count =
              if send_count[sender_id] < max_broadcasts do
                # Send
                send(pl, {:pl_send, sender_id, {:max_broadcast}})

                # Increment send
                Map.update!(send_count, sender_id, fn val -> val + 1 end)
              else
                send_count
              end

            max_broadcast(
              id,
              pl,
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
