defmodule LPL do
  def start(id, reliability) do
    receive do
      {:bind, client_pid, peers} ->
        # IO.puts("LPL#{id} initialised #{inspect(client_pid)} #{inspect(peers)}")
        next(id, reliability, client_pid, peers)
    end
  end

  defp next(id, reliability, client_pid, peers) do
    receive do
      {:pl_send, recipient_id, payload} ->
        # Only send if random number smaller than reliability
        if Helper.random(100) <= reliability do
          send(peers[recipient_id], {:deliver, id, payload})
        end

      {:deliver, sender_id, payload} ->
        send(client_pid, {:pl_deliver, sender_id, payload})
    end

    next(id, reliability, client_pid, peers)
  end
end
