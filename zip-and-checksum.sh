#!/bin/bash

OUT_FN=`basename $1 .img`.zip
zip -9 ${OUT_FN} $1
echo ${OUT_FN}
echo "SHA1: `sha1sum ${OUT_FN} | cut -f1 -d' '`"
echo "MD5: `md5sum ${OUT_FN} | cut -f1 -d' '`"
echo "SHA256: `sha256sum ${OUT_FN} | cut -f1 -d' '`"

