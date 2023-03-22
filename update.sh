#!/bin/bash
set -e

## we have disabled both command. because we faced a issue when we are upgrading mautic version to 3.2.1 and in mautic relases notes it showing latest version for mautic is available is 2.16.4. so. that's why we decided to use static version to ignore this ERROR.
# REF: https://github.com/mautic/mautic/releases/latest
#current="$(curl https://api.github.com/repos/mautic/mautic/releases/latest -s | jq -r .name)"
#current="$(echo $current | sed 's/Mautic Community //g')"

# mautic version
current=4.4.7

echo "Mautic version is: $current"

# TODO - Expose SHA signatures for the packages somewhere
wget -O mautic.zip https://github.com/mautic/mautic/releases/download/$current/$current.zip
sha1="$(sha1sum mautic.zip | sed -r 's/ .*//')"

for variant in apache fpm; do
	(
		set -x

		sed -ri '
			s/^(ENV MAUTIC_VERSION) .*/\1 '"$current"'/;
			s/^(ENV MAUTIC_SHA1) .*/\1 '"$sha1"'/;
		' "$variant/Dockerfile"

        # To make management easier, we use these files for all variants
		cp common/* "$variant"/
	)
done

rm mautic.zip
