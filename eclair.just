
# Execute a lightning-cli command (CLN)


# Remove color codes from json output with this sed expression 
decolorize_expr := '''
s/\x1B[@A-Z\\\]^_]\|\x1B\[[0-9:;<=>?]*[-!"#$%&'"'"'()*+,.\/]*[][\\@A-Z^_`a-z{|}~]//g
'''

eclair_default_password := 'eclair'

[private]
[group("eclair")]
exec container_name +command:
  @docker exec -t {{container_name}} eclair-cli -p {{eclair_default_password}} {{command}} | sed --expression='{{decolorize_expr}}'

[private]
[group("eclair")]
id container_name:
  @just eclair::exec {{container_name}} getinfo | jq --raw-output .nodeId 
