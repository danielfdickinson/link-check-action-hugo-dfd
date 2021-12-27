#/bin/bash

set -o pipefail

if HUGO_MINIFY_TDEWOLFF_HTML_KEEPCOMMENTS=true HUGO_ENABLEMISSINGTRANSLATIONPLACEHOLDERS=true hugo --gc --cleanDestinationDir  --destination $(pwd)/public --source $(pwd)/src && \
    grep -iIvrnE "grep(.+(-- raw HTML omitted --|ZgotmplZ|hahahugo|\\\[i18n\\\])+)" public/ | \
    grep -iIoE "<\!-- raw HTML omitted -->|ZgotmplZ|hahahugo|\[i18n\]"
then
    echo "not ok"
    exit 1
else
    echo "ok"
    exit 0
fi
