defmodule Handlers.UpdatePincode do
  def handle(storage, update_pincode) do
    {:ok, account} = Cachex.get(:accounts, storage.login)

    Cachex.set!(
      :accounts,
      storage.login,
      Map.update(account, :pincode, update_pincode.hash, fn _ ->
        update_pincode.hash
      end)
    )

    <<942::16, 0x00, 0x00>>
  end
end
