
# Execute a lightning-cli command (CLN)


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

[private]
[group("eclair")]
exec container_name +command:
  @docker exec -t {{container_name}} eclair-cli -p {{eclair_default_password}} {{command}}

[private]
[group("eclair")]
id container_name:
  @just eclair::exec {{container_name}} getinfo | sed --expression='{{decolorize_expr}}' | jq --raw-output .nodeId

[private]
[group("eclair")]
newaddr container_name:
  @just eclair::exec {{container_name}} getnewaddress | sed --expression='{{remove_nonprintchars_expr}}'
