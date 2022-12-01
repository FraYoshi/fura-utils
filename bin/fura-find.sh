#!/bin/bash -

if [[ $1 ]]; then
    WHERE="$1"
else
    echo -n "where to search? "
    read -r WHERE
fi

if [[ $2 ]]; then
    WHAT="$2"
else
    echo -n "what to search? "
    read -r WHAT
fi

echo "searching $WHAT in $WHERE"
find "$WHERE" -type f -iname "$WHAT" 2>&1 | grep -v "Permission denied"
echo "end of search."
