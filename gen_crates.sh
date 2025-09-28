#!/bin/bash

distfiles=('distfiles=')
checksum=('checksum=')
skip_extraction=('skip_extraction=')
post_extract=('post_extract()')

while read -r f; do
	grep crates.io "$f" > /dev/null || continue

	unset items source_url source_filename source_hash

	items=$(cat "$f" | grep '=' | tr -d " \$\`\t" | awk 'BEGIN{FS=OFS="="} {gsub("[-.&]","_",$1)}1')
	[ $? -eq 0 ] || exit 122
	#echo "$items"
	eval "$items" || exit 123
	[ -n "${source_url}" ] || continue

	#./subprojects/syn.wrap
	# directory=syn-2.0.87
	# source_url=https://crates.io/api/v1/crates/syn/2.0.87/download
	# source_filename=syn-2.0.87.tar.gz
	# source_hash=25aa4ce346d03a6dcd68dd8b4010bcb74e54e62c90c573f394c46eae99aba32d
	# patch_directory=syn
	distfiles+=( " ${source_url}>${source_filename}" )
	checksum+=( " $source_hash" )

	skip_extraction+=(" ${source_filename}")
	#echo "source_url: $source_url"
	name=$(echo "$source_url" | sed -r 's|.*crates/([^/]+)/([0-9.]+)/download|\1|')
	version=$(echo "$source_url" | sed -r 's|.*crates/([^/]+)/([0-9.]+)/download|\2|')
	post_extract+=("	_prepare_subproject ${name} ${version}")
done < <(find ./subprojects -maxdepth 1 -type f -name '*.wrap' -printf '%p\n')

printf "%s\n" "${distfiles[@]}"
printf "%s\n" "${checksum[@]}"
printf "%s\n" "${skip_extraction[@]}"
printf "%s\n" "${post_extract[@]}"

