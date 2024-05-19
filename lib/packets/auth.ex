defmodule Packets.Auth do
  @spec decode(<<_::16, _::_*8>>) :: %{
          client_version: char(),
          is_cheat: char(),
          login: binary(),
          mac: binary(),
          password: binary()
        }
  def decode(data) do
    <<
      key_len::16,
      key::bytes-size(key_len),
      login_len::16,
      login::bytes-size(login_len),
      password_len::16,
      password::bytes-size(password_len),
      mac_len::16,
      mac::bytes-size(mac_len),
      is_cheat::16,
      client_version::16
    >> = data

    login_string = :binary.part(login, 0, login_len - 1)
    mac_string = :binary.part(mac, 0, mac_len - 1)

    %{
      login: login_string,
      password: :binary.encode_hex(password),
      mac: mac_string,
      is_cheat: is_cheat,
      client_version: client_version
    }
  end
end
