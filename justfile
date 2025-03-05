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
lnd0_container_name := 'regtest_lnd0_bob'
lnd0_lightning_port := '9735'

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
  docker compose --file ./docker-compose.yml {{command}}

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
