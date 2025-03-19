# https://docs.corelightning.org/reference/lightningd-config


# Execute a lightning-cli command (CLN)
[private]
[group("cln")]
exec container_name +command:
  @docker exec -t {{container_name}} lightning-cli --lightning-dir=/home/clightning/.lightning --regtest {{command}}

[private]
[group("cln")]
id container_name:
  @just cln::exec {{container_name}} --json getinfo | jq --raw-output .id

[private]
[group("cln")]
newaddr container_name:
  @just cln::exec {{container_name}} --json newaddr | jq --raw-output .bech32

[private]
[group("cln")]
connect container_name id host port:
  @just cln::exec {{container_name}} --keywords connect "id"={{id}} "host"={{host}} "port"={{port}}

[private]
[group("cln")]
create-invoice container_name amount_msat='1000' label=uuid() description=uuid() *args='':
  @just cln::exec {{container_name}} --keywords invoice "amount_msat"={{amount_msat}} "label"={{label}} "description"={{description}} {{args}}

[private]
[group("cln")]
fundchannel container_name id amount_sat='1000000' feerate='1' announce='true' minconf='6' push_msat='500000000':
  @just cln::exec {{container_name}} --keywords fundchannel "id"={{id}} "amount"={{amount_sat}} "feerate"={{feerate}} "announce"={{announce}} "minconf"={{minconf}} "push_msat"={{push_msat}} "mindepth"="0"
