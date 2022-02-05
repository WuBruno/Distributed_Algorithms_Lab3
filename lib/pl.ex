defmodule PL do
  def start(id) do
    receive do
      {:bind, client_pid, peers} ->
        # IO.puts("PL#{id} initialised #{inspect(client_pid)} #{inspect(peers)}")
        next(id, client_pid, peers)
    end
  end

  defp next(id, client_pid, peers) do
    receive do
      {:pl_send, recipient_id, payload} -> send(peers[recipient_id], {:deliver, id, payload})
      {:deliver, sender_id, payload} -> send(client_pid, {:pl_deliver, sender_id, payload})
    end

    next(id, client_pid, peers)
  end
end
