defmodule Client do
  def start(id) do
    receive do
      {:bind, erb, peers} ->
        # IO.puts("Client#{id} initialised #{inspect(pl)} #{inspect(peers)}")
        next(id, erb, peers)
    end
  end

  defp next(id, erb, peers) do
    receive do
      {:rb_deliver, _sender, {:broadcast, max_broadcasts, timeout}} ->
        send_count = 1
        receive_count = for peer_id <- peers, into: %{}, do: {peer_id, 0}
        # Begin max_broadcasts
        send(erb, {:rb_broadcast, {:max_broadcast, id, send_count}})

        IO.puts("Peer#{id} received and started max_broadcast")

        # Set up timeout
        Process.send_after(self(), {:timeout}, timeout)

        max_broadcast(
          id,
          erb,
          peers,
          max_broadcasts,
          send_count,
          receive_count
        )
    end
  end

  defp max_broadcast(
         id,
         erb,
         peers,
         max_broadcasts,
         send_count,
         receive_count
       ) do
    receive do
      {:timeout} ->
        output_count(id, send_count, receive_count)

      {:rb_deliver, sender, _payload} ->
        IO.puts("Peer#{id} RB message received")

        max_broadcast(
          id,
          erb,
          peers,
          max_broadcasts,
          send_count + 1,
          increment_receive(receive_count, sender)
        )
    end
  end

  defp increment_receive(receive_count, id),
    do: Map.update!(receive_count, id, fn count -> count + 1 end)

  defp output_count(id, send_count, receive_count) do
    IO.puts(
      "Peer#{id}:  " <>
        for(
          {_k, rc} <- receive_count,
          into: "",
          do: "{#{send_count}, #{rc}}  "
        )
    )
  end
end

# Client

# case payload do
#   {:max_broadcast} ->
#     # Increment receive
#     receive_count = Map.update!(receive_count, sender_id, fn val -> val + 1 end)

#     # Increment send count
#     send_count =
#       if send_count[sender_id] < max_broadcasts do
#         # Send
#         send(pl, {:pl_send, sender_id, {:max_broadcast}})

#         # Increment send
#         Map.update!(send_count, sender_id, fn val -> val + 1 end)
#       else
#         send_count
#       end

#     max_broadcast(
#       id,
#       pl,
#       peers,
#       max_broadcasts,
#       timeout,
#       send_count,
#       receive_count
#     )

#   _ ->
#     nil
# end
