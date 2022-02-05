defmodule PL do
  def start(id) do
    receive do
      {:bind, parent, peers} ->
        # IO.puts("PL#{id} initialised #{inspect(client_pid)} #{inspect(peers)}")
        next(id, parent, peers)
    end
  end

  defp next(id, parent, peers) do
    receive do
      {:pl_send, recipient, payload} ->
        send(peers[recipient], {:deliver, id, payload})

      {:deliver, from, payload} ->
        send(parent, {:pl_deliver, from, payload})
    end

    next(id, parent, peers)
  end
end
