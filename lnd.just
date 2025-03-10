# Execute a lncli-cli command (LND)
[private]
[group("lnd")]
lnd-exec container_name +command:
  @docker exec -t {{container_name}} lncli --lnddir=/home/lnd/.lnd --network=regtest --no-macaroons {{command}}

[private]
[group("lnd")]
lnd-newaddr container_name address_type='p2wkh':
  @just lnd::lnd-exec {{container_name}} newaddress {{address_type}} | jq --raw-output .address

[private]
[group("lnd")]
lnd-id container_name:
  @just lnd::lnd-exec {{container_name}} getinfo | jq --raw-output .identity_pubkey

[private]
[group("lnd")]
lnd-openchannel container_name id amount_sat='1000000' push_sat='500000':
  @just lnd::lnd-exec {{container_name}} openchannel --node_key {{id}} --local_amt {{amount_sat}} --push_amt {{push_sat}}

[private]
[group("lnd")]
lnd-create-invoice container_name amount_msat='1000':
  @just lnd::lnd-exec {{container_name}} addinvoice --amt_msat {{amount_msat}}
