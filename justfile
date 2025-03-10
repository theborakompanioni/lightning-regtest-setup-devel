# This justfile requires https://github.com/casey/just

mod bitcoin
mod cln
mod lnd

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
cln3_container_name := 'regtest_cln3_charlie'
cln3_lightning_port := '19846'
cln4_container_name := 'regtest_cln4_dave'
cln5_container_name := 'regtest_cln5_erin'
cln5_lightning_port := '19846'
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

# Execute a command on instance "cln0"
[group("cln0")]
cln0-exec +command:
  @just cln::exec {{cln0_container_name}} {{command}}

[private]
[group("cln3")]
cln3-exec +command:
  @just cln::exec {{cln3_container_name}} {{command}}

# Execute a command on instance "lnd6"
[group("lnd6")]
lnd6-exec +command:
  @just lnd::exec {{lnd6_container_name}} {{command}}

[private]
[group("lnd6")]
lnd6-connect-cln3:
  #!/usr/bin/env bash
  set -euxo pipefail
  just lnd::exec {{lnd6_container_name}} disconnect $(just cln3-id) || :
  just lnd::exec {{lnd6_container_name}} connect $(just cln3-id)@{{cln3_container_name}}:{{cln3_lightning_port}} --timeout 30s --perm

[private]
[group("cln0")]
cln0-id:
  @just cln::id {{cln0_container_name}}

[private]
[group("cln1")]
cln1-id:
  @just cln::id {{cln1_container_name}}

[private]
[group("cln2")]
cln2-id:
  @just cln::id {{cln2_container_name}}

[private]
[group("cln3")]
cln3-id:
  @just cln::id {{cln3_container_name}}

[private]
[group("cln5")]
cln5-id:
  @just cln::id {{cln5_container_name}}

[private]
[group("lnd6")]
lnd6-id:
  @just lnd::id {{lnd6_container_name}}

[private]
[group("cln0")]
cln0-connect id host port:
  @just cln::connect {{cln0_container_name}} {{id}} {{host}} {{port}}

[private]
[group("cln0")]
cln0-connect-cln1:
  #!/usr/bin/env bash
  set -euxo pipefail
  just cln::connect {{cln0_container_name}} $(just cln1-id) {{cln1_container_name}} {{cln1_lightning_port}}

[private]
[group("cln0")]
cln0-connect-cln2:
  #!/usr/bin/env bash
  set -euxo pipefail
  just cln::connect {{cln0_container_name}} $(just cln2-id) {{cln2_container_name}} {{cln2_lightning_port}}

[private]
[group("cln2")]
cln2-connect-cln3:
  #!/usr/bin/env bash
  set -euxo pipefail
  just cln::connect {{cln2_container_name}} $(just cln3-id) {{cln3_container_name}} {{cln3_lightning_port}}

[private]
[group("cln3")]
cln3-connect-cln5:
  #!/usr/bin/env bash
  set -euxo pipefail
  just cln::connect {{cln3_container_name}} $(just cln5-id) {{cln5_container_name}} {{cln5_lightning_port}}

[private]
[group("cln3")]
cln3-connect-lnd6:
  #!/usr/bin/env bash
  set -euxo pipefail
  just cln::connect {{cln3_container_name}} $(just lnd6-id) {{lnd6_container_name}} {{lnd6_lightning_port}}

[private]
[group("cln0")]
cln0-fundchannel-cln1 amount_sat='16777215' feerate='1' announce='true' minconf='6' push_msat='8388607500':
  #!/usr/bin/env bash
  set -euxo pipefail
  just cln::fundchannel {{cln0_container_name}} $(just cln1-id) {{amount_sat}} {{feerate}} {{announce}} {{minconf}} {{push_msat}}

[private]
[group("cln0")]
cln0-fundchannel-cln2 amount_sat='8388607' feerate='1' announce='true' minconf='6' push_msat='4194303500':
  #!/usr/bin/env bash
  set -euxo pipefail
  just cln::fundchannel {{cln0_container_name}} $(just cln2-id) {{amount_sat}} {{feerate}} {{announce}} {{minconf}} {{push_msat}}

[private]
[group("cln2")]
cln2-fundchannel-cln3 amount_sat='4194303' feerate='1' announce='true' minconf='6' push_msat='2097151500':
  #!/usr/bin/env bash
  set -euxo pipefail
  just cln::fundchannel {{cln2_container_name}} $(just cln3-id) {{amount_sat}} {{feerate}} {{announce}} {{minconf}} {{push_msat}}

[private]
[group("cln3")]
cln3-fundchannel-cln5 amount_sat='2097151' feerate='1' announce='false' minconf='6' push_msat='1048575500':
  #!/usr/bin/env bash
  set -euxo pipefail
  just cln::fundchannel {{cln3_container_name}} $(just cln5-id) {{amount_sat}} {{feerate}} {{announce}} {{minconf}} {{push_msat}}

[private]
[group("lnd6")]
lnd6-fundchannel-cln3 amount_sat='4194303' push_sat='2097151':
  #!/usr/bin/env bash
  set -euxo pipefail
  just lnd::openchannel {{lnd6_container_name}} $(just cln3-id) {{amount_sat}} {{push_sat}}

[group("cln0")]
cln0-help:
  @just cln0-exec help

[group("cln0")]
cln0-getinfo:
  @just cln0-exec getinfo

[group("cln0")]
cln0-invoice amount_msat='1000' label=uuid():
  @just cln::create-invoice {{cln0_container_name}} {{amount_msat}} {{label}} | jq --raw-output .bolt11

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
  @just cln::newaddr {{cln0_container_name}}

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
setup-fund-wallets:
  #!/usr/bin/env bash
  set -euxo pipefail
  just bitcoin::mine 2 $(just cln::newaddr {{cln0_container_name}})
  just bitcoin::mine 1 $(just cln::newaddr {{cln1_container_name}})
  just bitcoin::mine 1 $(just cln::newaddr {{cln2_container_name}})
  just bitcoin::mine 1 $(just cln::newaddr {{cln3_container_name}})
  just bitcoin::mine 1 $(just cln::newaddr {{cln4_container_name}})
  just bitcoin::mine 1 $(just cln::newaddr {{cln5_container_name}})
  just bitcoin::mine 1 $(just lnd::newaddr {{lnd6_container_name}})

[private]
[group("setup")]
setup-connect-peers:
  @just cln0-connect-cln1
  @just cln0-connect-cln2
  @just cln2-connect-cln3
  @just cln3-connect-cln5
  #@just lnd6-connect-cln3
  @just cln3-connect-lnd6

[private]
[group("setup")]
setup-create-channels:
  @just cln0-fundchannel-cln1
  @just cln0-fundchannel-cln2
  @just cln2-fundchannel-cln3
  @just cln3-fundchannel-cln5
  @just lnd6-fundchannel-cln3

# Send payments back and forth cln0<->cln5
[private]
[group("health")]
probe-payment-cln0-cln5:
  #!/usr/bin/env bash
  set -euxo pipefail
  # cln0<->cln5
  ## cln0->cln5
  INVOICE0_LABEL=$(printf "healthcheck_%s" "$(uuidgen -t)")
  INVOICE0_BOLT11=$(just cln::create-invoice {{cln5_container_name}} 1000 "${INVOICE0_LABEL}" | jq --raw-output .bolt11)
  just cln::exec {{cln0_container_name}} pay "${INVOICE0_BOLT11}"
  just cln::exec {{cln5_container_name}} waitinvoice "${INVOICE0_LABEL}"
  ## cln5->cln0
  INVOICE1_LABEL=$(printf "healthcheck_%s" "$(uuidgen -t)")
  INVOICE1_BOLT11=$(just cln::create-invoice {{cln0_container_name}} 1000 "${INVOICE1_LABEL}" | jq --raw-output .bolt11)
  just cln::exec {{cln5_container_name}} pay "${INVOICE1_BOLT11}"
  just cln::exec {{cln0_container_name}} waitinvoice "${INVOICE1_LABEL}"
  echo "HEALTHCHECK SUCCESS (cln0<->cln5)."

# Send payments back and forth between cln1<->lnd6
[private]
[group("health")]
probe-payment-cln1-lnd6:
  #!/usr/bin/env bash
  set -euxo pipefail
  # cln1<->lnd6
  ## lnd6->cln1
  INVOICE0_LABEL=$(printf "healthcheck_%s" "$(uuidgen -t)")
  INVOICE0_BOLT11=$(just cln::create-invoice {{cln1_container_name}} 1000 "${INVOICE0_LABEL}" | jq --raw-output .bolt11)
  just lnd::exec {{lnd6_container_name}} sendpayment --force --pay_req="${INVOICE0_BOLT11}"
  just cln::exec {{cln1_container_name}} waitinvoice "${INVOICE0_LABEL}"
  ## cln1->lnd6
  INVOICE1_BOLT11=$(just lnd::create-invoice {{lnd6_container_name}} 1000 | jq --raw-output .payment_request)
  just cln::exec {{cln1_container_name}} pay "${INVOICE1_BOLT11}"
  echo "HEALTHCHECK SUCCESS (cln1<->lnd6)."

# Send payments back and forth between cln0<->cln5 and cln1<->lnd6
[group("health")]
probe-payment:
  #!/usr/bin/env bash
  set -euxo pipefail
  while true; do
    just probe-payment-cln0-cln5
    just probe-payment-cln1-lnd6
    sleep 3
  done

# Initialize lightning; fund wallets, connect peers and create channels
[private]
[group("setup")]
init-lightning:
  @just bitcoin::mine 1
  @just cln0-waitblockheight 1
  @just setup-fund-wallets # mines 8 blocks; afterwards blockheight := 5
  @just bitcoin::mine 100
  @just cln0-waitblockheight 109
  @just setup-connect-peers
  @just setup-create-channels
  @just bitcoin::mine 6
  @just cln0-waitblockheight 115
  @just bitcoin::mine 6
  @just cln0-waitblockheight 121
  @just bitcoin::mine 10
  @just cln0-waitblockheight 131
  @just bitcoin::mine 1
  @just cln0-waitblockheight 132
  @just cln0-listchannels
  @just cln::exec {{cln0_container_name}} createrune

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
  @just cln0-id
  @echo "cln0 container name: {{cln0_container_name}}"
  @echo "cln0 rest endpoint: https://localhost:13010"
  @echo "cln0 swagger ui: https://localhost:13010/swagger-ui"
  @echo "cln0 getinfo:"
  @just cln::exec {{cln0_container_name}} getinfo | jq \
    | jq '{version, id, alias, num_peers, alias, num_pending_channels, num_active_channels, num_inactive_channels, blockheight, network, fees_collected_msat}'

  @echo "cln0 showrunes:"
  @just cln::exec {{cln0_container_name}} showrunes | jq
  @echo "## lnd6"
  @just lnd6-id
  @echo "lnd6 container name: {{lnd6_container_name}}"
  @echo "lnd6 rest endpoint: https://localhost:19841"
  @echo "lnd6 getinfo:"
  @curl --silent --insecure https://localhost:19841/v1/getinfo \
    | jq '{version, identity_pubkey, alias, num_peers, num_pending_channels, num_active_channels, num_inactive_channels, block_height, chains}'
