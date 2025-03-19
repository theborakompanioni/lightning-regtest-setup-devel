# https://acinq.github.io/eclair/

# Remove color codes from text with this sed expression
# e.g. this is needed for parsing "getinfo" response with `jq`
decolorize_expr := '''
s/\x1B[@A-Z\\\]^_]\|\x1B\[[0-9:;<=>?]*[-!"#$%&'"'"'()*+,.\/]*[][\\@A-Z^_`a-z{|}~]//g
'''

# Remove non-printable chars from text with this sed expression
# e.g. this is needed for parsing "getnewaddress" response before passing it on
remove_nonprintchars_expr := '''
s/[^[:print:]\t]//g
'''

eclair_default_password := 'eclair'

# Execute a eclair-cli command (eclair)
[private]
[group("eclair")]
exec container_name +command:
  @docker exec -t {{container_name}} eclair-cli -p {{eclair_default_password}} {{command}} | sed --expression='{{decolorize_expr}}'

[private]
[group("eclair")]
id container_name:
  @just eclair::exec {{container_name}} getinfo | jq --raw-output .nodeId

[private]
[group("eclair")]
newaddr container_name:
  @just eclair::exec {{container_name}} getnewaddress | sed --expression='{{remove_nonprintchars_expr}}'

[private]
[group("eclair")]
create-invoice container_name amount_msat='1000' description=uuid() *args='':
  @just eclair::exec {{container_name}} createinvoice --description={{description}} --amountMsat={{amount_msat}} {{args}}
