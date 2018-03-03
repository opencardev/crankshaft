#!/bin/bash

echo $1
echo "SHA1: `sha1sum $1 | cut -f1 -d' '`"
echo "MD5: `md5sum $1 | cut -f1 -d' '`"
echo "SHA256: `sha256sum $1 | cut -f1 -d' '`"

