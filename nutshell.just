

# Execute a cashu (nutshell wallet) command
[private]
[group("nutshell")]
exec container_name +command:
  @docker exec -t {{container_name}} poetry run cashu {{command}}

# Create Lighting invoice.
[private]
[group("nutshell")]
invoice container_name amount='21':
  @just nutshell::exec {{container_name}} invoice --no-check {{amount}}

# Balance.
[private]
[group("nutshell")]
balance container_name:
  @just nutshell::exec {{container_name}} balance --verbose

# Refresh tokens.
[private]
[group("nutshell")]
selfpay container_name:
  @just nutshell::exec {{container_name}} selfpay

# Try to mint pending invoices.
[private]
[group("nutshell")]
mint-pending-invoices container_name:
  @just nutshell::exec {{container_name}} invoices --mint

# List pending invoices.
[private]
[group("nutshell")]
list-pending-invoices container_name:
  @just nutshell::exec {{container_name}} invoices --pending


# List pending invoices.
[private]
[group("nutshell")]
pay container_name invoice:
  @just nutshell::exec {{container_name}} pay --yes {{invoice}}

[private]
[group("nutshell")]
help container_name:
  @just nutshell::exec {{container_name}} --help
