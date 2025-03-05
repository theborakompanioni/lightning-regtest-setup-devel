# This justfile requires https://github.com/casey/just

mod bitcoin

# Load environment variables from `.env` file.
set dotenv-load
# Fail the script if the env file is not found.
set dotenv-required

project_dir := justfile_directory()
cln0_container_name := 'regtest_cln0_app'
cln1_container_name := 'regtest_cln1_alice'
cln1_lightning_port := '19846'
cln2_container_name := 'regtest_cln2_bob'
cln2_lightning_port := '19846'
lnd6_container_name := 'regtest_lnd6_farid'
lnd6_lightning_port := '9735'

# print available targets
[group("project-agnostic")]
default:
  @just --list --justfile {{justfile()}}

# evaluate and print all just variables
[group("project-agnostic")]
evaluate:
  @just --evaluate

# print system information such as OS and architecture
[group("project-agnostic")]
system-info:
  @echo "architecture: {{arch()}}"
  @echo "os: {{os()}}"
  @echo "os family: {{os_family()}}"

# checks if docker and docker compose is installed and running
[private]
[group("setup")]
check-deps:
  @just check-docker
  @just check-jq

# checks if jq is installed
[private]
[group("setup")]
check-jq:
  #!/usr/bin/env bash
  if ! command -v jq &> /dev/null; then
    >&2 echo 'Error: jq is not installed.';
    exit 1;
  fi

# checks if docker and docker compose is installed and running
[private]
[group("setup")]
check-docker:
  #!/usr/bin/env bash
  if ! command -v docker &> /dev/null; then
    >&2 echo 'Error: Docker is not installed.';
    exit 1;
  fi

  if ! command -v docker compose &> /dev/null; then
   >&2 echo 'Error: Docker Compose is not installed.' >&2;
   exit 1;
  fi

  if ! command docker info &> /dev/null; then
    >&2 echo 'Error: Docker is not running.';
    exit 1;
  fi

# Execute a command in a running container
[group("docker")]
docker-exec +command: check-docker
  @docker compose --file ./docker-compose.yml {{command}}

# Create and start containers
[group("docker")]
up *args='':
  @just docker-exec up --detach --wait --wait-timeout 120 {{args}}

# Stop containers
[group("docker")]
down *args='':
  @just docker-exec down {{args}}

# Stop and remove containers, networks and volumes
[group("docker")]
clean:
  rm --force ./.docker_data/bitcredit_wallet/bills_keys/*.json
  @just down --remove-orphans --volumes

# Build or rebuild services
[group("docker")]
build *args='':
  @just docker-exec build {{args}}

# Rebuild services without cache
[group("docker")]
rebuild *args='':
  @just build --no-cache {{args}}

# View and follow output from containers
[group("docker")]
logs *args='':
  @just docker-exec logs --follow {{args}}

# List containers
[group("docker")]
ps *args='':
  @just docker-exec ps {{args}}

# Execute a lncli-cli command (LND)
[private]
[group("lnd")]
lnd-exec container_name +command:
  @docker exec -t {{container_name}} lncli --lnddir=/home/lnd/.lnd --network=regtest --no-macaroons {{command}}

# Execute a lightning-cli command (CLN)
[private]
[group("cln")]
cln-exec container_name +command:
  @docker exec -t {{container_name}} lightning-cli --lightning-dir=/home/clightning/.lightning --regtest {{command}}

[private]
[group("cln")]
cln-newaddr container_name:
  @just cln-exec {{container_name}} --json newaddr | jq --raw-output .bech32

[private]
[group("cln")]
cln-connect container_name id host port:
  @just cln-exec {{container_name}} --keywords connect "id"={{id}} "host"={{host}} "port"={{port}}

[private]
[group("cln0")]
cln-fundchannel container_name id amount_sat='1000000' feerate='1' announce='true' minconf='6' push_msat='500000000':
  just cln-exec {{container_name}} --keywords fundchannel "id"={{id}} "amount"={{amount_sat}} "feerate"={{feerate}} "announce"={{announce}} "minconf"={{minconf}} "push_msat"={{push_msat}} "mindepth"="0"

# Execute a command on instance "cln0"
[group("cln0")]
cln0-exec +command:
  @just cln-exec {{cln0_container_name}} {{command}}

# Execute a command on instance "cln1"
[group("cln1")]
cln1-exec +command:
  @just cln-exec {{cln1_container_name}} {{command}}

# Execute a command on instance "lnd6"
[group("lnd6")]
lnd6-exec +command:
  @just lnd-exec {{lnd6_container_name}} {{command}}

[group("cln1")]
cln1-id:
  @just cln-exec {{cln1_container_name}} --json getinfo | jq --raw-output .id

[group("cln2")]
cln2-id:
  @just cln-exec {{cln2_container_name}} --json getinfo | jq --raw-output .id

[group("lnd6")]
lnd6-id:
  @just lnd6-exec getinfo | jq --raw-output .identity_pubkey

[private]
[group("cln0")]
cln0-connect id host port:
  @just cln-connect {{cln0_container_name}} {{id}} {{host}} {{port}}

[private]
[group("cln0")]
cln0-connect-cln1:
  #!/usr/bin/env bash
  set -euxo pipefail
  just cln-connect {{cln0_container_name}} $(just cln1-id) {{cln1_container_name}} {{cln1_lightning_port}}

[private]
[group("cln0")]
cln0-connect-cln2:
  #!/usr/bin/env bash
  set -euxo pipefail
  just cln-connect {{cln0_container_name}} $(just cln2-id) {{cln2_container_name}} {{cln2_lightning_port}}

[private]
[group("cln0")]
cln0-connect-lnd6:
  #!/usr/bin/env bash
  set -euxo pipefail
  just cln-connect {{cln0_container_name}} $(just lnd6-id) {{lnd6_container_name}} {{lnd6_lightning_port}}

[private]
[group("cln0")]
cln0-fundchannel-cln1 amount_sat='16777215' feerate='1' announce='true' minconf='6' push_msat='8388607500':
  #!/usr/bin/env bash
  set -euxo pipefail
  just cln-fundchannel {{cln0_container_name}} $(just cln1-id) {{amount_sat}} {{feerate}} {{announce}} {{minconf}} {{push_msat}}

[private]
[group("cln0")]
cln0-fundchannel-cln2 amount_sat='8388607' feerate='1' announce='true' minconf='6' push_msat='4194303500':
  #!/usr/bin/env bash
  set -euxo pipefail
  just cln-fundchannel {{cln0_container_name}} $(just cln2-id) {{amount_sat}} {{feerate}} {{announce}} {{minconf}} {{push_msat}}

[private]
[group("cln0")]
cln0-fundchannel-lnd6 amount_sat='1000000' feerate='1' announce='true' minconf='6' push_msat='500000000':
  #!/usr/bin/env bash
  set -euxo pipefail
  just cln0-exec --keywords fundchannel "id"=$(just lnd6-id) "amount"={{amount_sat}} "announce"={{announce}} "minconf"={{minconf}} "push_msat"={{push_msat}} "mindepth"="0"

[group("cln0")]
cln0-help:
  @just cln0-exec help

[group("cln0")]
cln0-getinfo:
  @just cln0-exec getinfo

[private]
[group("cln0")]
cln0-create-invoice amount_msat='1000' label=uuid() description=uuid():
  @just cln0-exec --keywords invoice "amount_msat"={{amount_msat}} "label"={{label}} "description"={{description}}

[group("cln0")]
cln0-invoice amount_msat='1000':
  @just cln0-create-invoice {{amount_msat}} | jq --raw-output .bolt11

[group("cln0")]
cln0-listinvoices:
  @just cln0-exec listinvoices

[group("cln0")]
cln0-listbalances:
  @just cln0-exec bkpr-listbalances

[group("lnd6")]
lnd6-getinfo:
  @just lnd6-exec getinfo

[group("cln0")]
cln0-listchannels:
  @just cln0-exec listchannels

[private]
[group("cln0")]
cln0-waitblockheight blockheight timeout='5':
  @just cln0-exec --keywords waitblockheight "blockheight"={{blockheight}} "timeout"={{timeout}}

[group("cln0")]
cln0-listpeers:
  @just cln0-exec listpeers

# Generate a new on-chain address of the internal wallet
[group("cln0")]
cln0-newaddr:
  @just cln-newaddr {{cln0_container_name}}

# Send funds on-chain from the internal wallet
[group("cln0")]
cln0-sendtx destination amount_sat='21000' *args='':
  @just cln0-exec --keywords withdraw "destination"={{destination}} "satoshi"={{amount_sat}} {{args}}

# Show all funds currently managed
[group("cln0")]
cln0-listfunds spent='false':
  @just cln0-exec --keywords --json listfunds "spent"={{spent}}

[private]
[group("setup")]
setup-fund-cln0:
  #!/usr/bin/env bash
  set -euxo pipefail
  just bitcoin::mine 1 $(just cln-newaddr {{cln0_container_name}})

[private]
[group("setup")]
setup-fund-wallets:
  #!/usr/bin/env bash
  set -euxo pipefail
  just bitcoin::mine 2 $(just cln-newaddr {{cln0_container_name}})
  just bitcoin::mine 1 $(just cln-newaddr {{cln1_container_name}})
  just bitcoin::mine 1 $(just cln-newaddr {{cln2_container_name}})

[private]
[group("setup")]
setup-connect-peers:
  @just cln0-connect-cln1
  @just cln0-connect-cln2
  #@just cln0-connect-lnd6

# Initialize lightning; fund wallets, connect peers and create channels
[private]
[group("setup")]
init-lightning:
  @just bitcoin::mine 1
  @just cln0-waitblockheight 1
  @just setup-fund-wallets # mines 4 blocks; afterwards blockheight := 5
  @just bitcoin::mine 100
  @just cln0-waitblockheight 105
  @just setup-connect-peers
  @just cln0-fundchannel-cln1
  @just cln0-fundchannel-cln2
  @just bitcoin::mine 6
  @just cln0-waitblockheight 111
  #@just cln0-fundchannel-lnd6
  @just bitcoin::mine 6
  @just cln0-waitblockheight 117
  @just bitcoin::mine 10
  @just cln0-waitblockheight 127
  @just bitcoin::mine 1
  @just cln0-waitblockheight 128
  @just cln0-listchannels
  @just cln-exec {{cln0_container_name}} createrune

# Initialize setup; setup lightning infra and ebill data
[group("setup")]
init: check-deps
  @just init-lightning

# Initialize setup; setup lightning infra and ebill data
[group("info")]
info:
  @echo "# lightning-regtest-setup-devel"
  @echo "## bitcoin"
  @just bitcoin::info
  @echo "## cln0"
  @echo "cln0 container name: {{cln0_container_name}}"
  @echo "cln0 rest endpoint: https://localhost:13010"
  @echo "cln0 swagger ui: https://localhost:13010/swagger-ui"
  @just cln-exec {{cln0_container_name}} getinfo
  @just cln-exec {{cln0_container_name}} showrunes
