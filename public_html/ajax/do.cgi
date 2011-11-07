#! /bin/sh
#
# This is an extremely basic script that acts as a proxy for our (much faster)
# application server running at http://$HOST:$PORT.
#
# This script allows us to use HTTPS authentication on the front end.
#
HOST=vergil.u.washington.edu
PORT=30333

POST                                \
    -e                              \
    -m "$REQUEST_METHOD"            \
    -H "Cookie: $HTTP_COOKIE"       \
    "http://$HOST:$PORT$PATH_INFO"
