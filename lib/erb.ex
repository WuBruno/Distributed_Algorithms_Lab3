defmodule ERB do
  def start(id) do
    receive do
      {:bind, beb, parent} ->
        next(id, beb, parent, MapSet.new())
    end
  end

  defp next(id, beb, parent, delivered) do
    receive do
      {:rb_broadcast, payload} ->
        send(beb, {:beb_broadcast, {:rb_data, id, payload}})
        next(id, beb, parent, delivered)

      {:beb_deliver, _from, {:rb_data, sender, payload} = rb_m} ->
        if payload in delivered do
          next(id, beb, parent, delivered)
        else
          send(parent, {:rb_deliver, sender, payload})
          send(beb, {:beb_broadcast, rb_m})
          next(id, beb, parent, MapSet.put(delivered, payload))
        end
    end
  end
end
