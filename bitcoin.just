bitcoin_container_name := 'regtest_bitcoind'
bitcoin_container_rpcport := '18443'

# Execute a bitcoin-cli command
[group("bitcoin")]
exec +command:
  docker exec -t {{bitcoin_container_name}} bitcoin-cli -datadir=/home/bitcoin/.bitcoin -regtest -rpcport=18443 {{command}}

# Get general information from the bitcoin daemon
[group("bitcoin")]
getinfo:
  @just bitcoin::exec -getinfo

# View state info regarding blockchain processing.
[group("bitcoin")]
getblockchaininfo:
  @just bitcoin::exec getblockchaininfo

# Mine to a specified address and return the block hashes.
[group("bitcoin")]
mine blocks='1' address='bcrt1qrnz0thqslhxu86th069r9j6y7ldkgs2tzgf5wx':
  @echo {{address}}
  @just bitcoin::exec generatetoaddress "{{blocks}}" "{{address}}"

# Print info of bitcoin service
[group("setup")]
info:
  @echo "# bitcoin"
  @echo "bitcoin container name: {{bitcoin_container_name}}"
  @echo "bitcoin container rpcport: {{bitcoin_container_rpcport}}"
