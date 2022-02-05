defmodule LPL do
  def start(id, reliability) do
    receive do
      {:bind, parent, peers} ->
        # IO.puts("LPL#{id} initialised #{inspect(parent)} #{inspect(peers)}")
        next(id, reliability, parent, peers)
    end
  end

  defp next(id, reliability, parent, peers) do
    receive do
      {:pl_send, recipient, payload} ->
        unreliable_send(reliability, peers[recipient], {:deliver, id, payload})

      {:deliver, from, payload} ->
        send(parent, {:pl_deliver, from, payload})
    end

    next(id, reliability, parent, peers)
  end

  defp unreliable_send(reliability, dest, payload) do
    if Helper.random(100) <= reliability do
      send(dest, payload)
    end
  end
end
