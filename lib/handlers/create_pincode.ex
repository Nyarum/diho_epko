defmodule Handlers.CreatePincode do
  def handle(storage, create_pincode) do
    {:ok, account} = Cachex.get(:accounts, storage.login)

    Cachex.set!(:accounts, storage.login, Map.put_new(account, :pincode, create_pincode.hash))

    <<941::16, 0x00, 0x00>>
  end
end
