#!/bin/bash

#distfiles=""
#checksum=""
#skip_extraction=""

_crates=()

while read -r f; do
	grep crates.io "$f" > /dev/null || continue

	_items=$(grep '=' "$f" | tr -d " \t")

	#./subprojects/syn.wrap
	# directory=syn-2.0.87
	# source_url=https://crates.io/api/v1/crates/syn/2.0.87/download
	# source_filename=syn-2.0.87.tar.gz
	# source_hash=25aa4ce346d03a6dcd68dd8b4010bcb74e54e62c90c573f394c46eae99aba32d
	# patch_directory=syn

	_source_url=$(grep 'source_url=' <<< "$_items"); _source_url=${_source_url#*=}
	[ -n "${_source_url}" ] || continue
	_source_filename=$(grep 'source_filename=' <<< "$_items"); _source_filename=${_source_filename#*=}
	_source_hash=$(grep 'source_hash=' <<< "$_items"); _source_hash=${_source_hash#*=}

	distfiles+=$'\n'" ${_source_url}>${_source_filename}"
	checksum+=$'\n'" $_source_hash"
	skip_extraction+=$'\n'" ${_source_filename}"

	__subname=$(sed -r 's|.*crates/([^/]+)/([0-9.]+)/download|\1|' <<< "$_source_url")
	__subversion=$(sed -r 's|.*crates/([^/]+)/([0-9.]+)/download|\2|' <<< "$_source_url")
	_crates+=("	_prepare_subproject ${__subname} ${__subversion}")
done < <(find ./subprojects -maxdepth 1 -type f -name '*.wrap' -printf '%p\n')

printf 'distfiles+="%s"\n' "$distfiles"
printf 'checksum+="%s"\n' "$checksum"
printf 'skip_extraction+="%s"\n' "$skip_extraction"

echo 'post_extract() {'
printf "%s\n" "${_crates[@]}"
echo '}'
