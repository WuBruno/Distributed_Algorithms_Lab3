defmodule BEB do
  def start(id) do
    receive do
      {:bind, pl, parent, peers} -> next(id, pl, parent, peers)
    end
  end

  defp next(id, pl, parent, peers) do
    receive do
      {:beb_broadcast, payload} ->
        for peer <- peers, do: send(pl, {:pl_send, peer, {:beb_broadcast, payload}})

      {:pl_deliver, from, payload} ->
        send(parent, {:beb_deliver, from, payload})
    end

    next(id, pl, parent, peers)
  end
end
