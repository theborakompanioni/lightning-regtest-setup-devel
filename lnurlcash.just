# https://github.com/lnurlcash/lnurl-mint

[private]
[group("lnurlcash")]
invoice url comment amount='21000':
  @curl --fail --silent --insecure "{{url}}/p/cb?amount={{amount}}&comment={{comment}}" | jq --raw-output .pr

# get the special note with secret set all to zeroes
[private]
[group("lnurlcash")]
invoice-zeroes url amount='21000':
  @just lnurlcash::invoice {{url}} "0000000000000000000000000000000000000000000000000000000000000000" {{amount}}
