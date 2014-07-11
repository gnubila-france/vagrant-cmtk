# Common functions for installing software

# extract_tarball $tarball
#
# Extract a tarball into the current dir
extract_tarball() {
  if [ $# -ne 1 ]; then
    echo 'extract_tarball: Wrong numbers of parameters:'
    echo 'extract_tarball tarball'
    exit 1
  fi

  local tarball="$1"
  assert_is_set extract_tarball tarball

  echo
  echo "Extracting $tarball in $(pwd)"
  tar xvf "$tarball"
  if [ $? -ne 0 ]; then
    echo "Failure unpacking $tarball"
    exit 1
  else
    echo 'Done.'
  fi
  fix_rights .
}

# extract_zip $zipfile
#
# Extract a tarball into the current dir
extract_zip() {
  if [ $# -ne 1 ]; then
    echo 'extract_zip: Wrong numbers of parameters:'
    echo 'extract_zip zipfile'
    exit 1
  fi

  local zipfile="$1"
  assert_is_set extract_zip zipfile

  echo
  echo "Extracting $1 in $(pwd)"
  unzip "$1"
  if [ $? -ne 0 ]; then
    echo "Failure unpacking $1"
    exit 1
  else
    echo 'Done.'
  fi
  fix_rights .
}

# fetch_file $file_url
#
# Fetch a file using wget
fetch_file() {
  if [ $# -ne 1 ]; then
    echo 'fetch_file: Wrong numbers of parameters:'
    echo 'fetch_file file_url'
    exit 1
  fi

  local file_url="$1"
  assert_is_set fetch_file file_url

  echo
  echo "Fetching $file_url in $(pwd)"
  wget "$file_url"
  if [ $? -ne 0 ]; then
    echo "Unable to download $file_url in $(pwd)"
    exit 1
  else
    echo 'Done.'
  fi
}

# assert_is_set caller_name variable_name
assert_is_set() {
  if [ $# -ne 2 ]; then
    echo 'assert_is_set: Wrong numbers of parameters:'
    echo 'assert_is_set caller_name variable_name'
    exit 1
  fi

  local caller_name="$1"
  local variable_name="$2"

  eval val=\$$variable_name
  if [ -z "$val" ] ; then
    echo "$caller_name: variable '$variable_name' is not defined or empty" >&2
    exit 1
  fi
}

# vim:set ft=sh ts=2 sw=2 expandtab:
