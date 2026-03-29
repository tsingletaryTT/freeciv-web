#!/usr/bin/env -S bash -e

# Places the specified revision of Freeciv in freeciv/freeciv/
# This is the default. The script dl_freeciv.sh will run instead of
# dl_freeciv_default.sh if it exists.
# If you want to modify this file copy it to dl_freeciv.sh and edit it.

if test "$2" != "" ; then
  GIT_PATCHING="$2"
else
  GIT_PATCHING="yes"
fi

echo "Updating freeciv to commit $1, git patching: $GIT_PATCHING"

# Remove old version
echo "  removing existing source"
rm -Rf freeciv

if test "$GIT_PATCHING" = "yes" ; then

  # TT-Lang: clone the TT-Lang patched Freeciv server (ttlang branch) instead
  # of vanilla freeciv/freeciv.  The ttlang branch is based on the same
  # add9f4e14 base commit as version.txt specifies, with three TT-Lang commits
  # on top (terrain gen, tile scoring, coastal fish filter).  All standard
  # freeciv-web patches in apply_patches.sh apply cleanly on top.
  git clone --no-tags --branch=ttlang --single-branch \
      https://github.com/tsingletaryTT/freeciv.git freeciv
  echo "TT-Lang: checked out $(git -C freeciv rev-parse --short HEAD) (ttlang branch)"

else

  # Download the wanted Freeciv revision from GitHub unless it is here already.
  # The download step saves having to merge in Freeciv's history each time the
  # Freeciv server revision is updated.
  echo "  fetching missing revisions"
  git cat-file -e $1 || git fetch --no-tags --depth=1 https://github.com/tsingletaryTT/freeciv.git ttlang:freeciv-ref || /bin/true

  # Place the requested Freeciv revision in the freeciv/freeciv folder.
  # The checkout isn't owned by git. This means that the patches automatically
  # applied during the build won't accidentally end up in commits. It also
  # means that committing unrelated changes won't accidentally revert the
  # Freeciv server revision because a command didn't run.
  echo "  checking out TT-Lang ttlang branch HEAD"
  git read-tree --prefix=freeciv/freeciv/ --index-output=.freeciv_index freeciv-ref
  mkdir freeciv && cd freeciv && GIT_INDEX_FILE=.freeciv_index git checkout-index -af && cd ..
  rm -f ../.freeciv_index

fi
