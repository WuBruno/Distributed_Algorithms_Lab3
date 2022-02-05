defmodule BEB do
  def start(id) do
    receive do
      {:bind, pl, client, peer_ids} -> next(id, pl, client, peer_ids)
    end
  end

  defp next(id, pl, client, peer_ids) do
    receive do
      {:beb_broadcast, payload} ->
        for peer_id <- peer_ids, do: send(pl, {:pl_send, peer_id, payload})

      # IO.puts("BEB#{id} broadcast")

      {:pl_deliver, sender_id, payload} ->
        send(client, {:beb_deliver, sender_id, payload})
    end

    next(id, pl, client, peer_ids)
  end
end
