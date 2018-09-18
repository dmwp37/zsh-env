#!/bin/zsh

if [ -r ~/.shell/zshrc ]; then
 . ~/.shell/zshrc
fi

# remove nonexistent directories from an array.
rationalize-path ()
{
  # Note that this works only on arrays, not colon-delimited strings.
  # Not that this is a problem now that there is typeset -T.
  local element
  local build
  build=()
  # Evil quoting to survive an eval and to make sure that
  # this works even with variables containing IFS characters, if I'm
  # crazy enough to setopt shwordsplit.
  eval '
  foreach element in "$'"$1"'[@]"
  do
    if [[ -d "$element" ]]
    then
      build=("$build[@]" "$element")
    fi
  done
  '"$1"'=( "$build[@]" )
  '
}

typeset -TU LD_LIBRARY_PATH ld_path  # Tie array to LD path
ld_path=( /usr/local/lib $ld_path  )

path=( /bin /usr/bin /sbin /usr/sbin /usr/local/sbin /usr/local/share/bin $path )
path=( ~/bin $JAVA_HOME/bin $JRE_HOME/bin $path )
rationalize-path path

# Remove duplicates
typeset -U path cdpath manpath fpath ld_path
