#!/bin/sh

# external-user.sh
# Who Am I?

cat <<EOF
{
  "user": "$(echo $USER)"
}
EOF