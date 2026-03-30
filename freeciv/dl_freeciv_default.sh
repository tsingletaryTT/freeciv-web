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

# TT-Lang: always clone the TT-Lang patched Freeciv server (ttlang branch).
# The ttlang branch is based on the same add9f4e14 base commit as version.txt
# specifies, with TT-Lang commits on top (terrain gen, tile scoring, coastal
# fish filter, tt_tile_cache + ttlang_height sources).  All standard
# freeciv-web patches in apply_patches.sh apply cleanly on top.
#
# GIT_PATCHING="no" means the checkout should not be a live git repo (so
# patches don't accidentally end up in commits).  We clone and then remove
# .git to satisfy this contract while still getting the right source tree.
echo "TT-Lang: cloning tsingletaryTT/freeciv (ttlang branch)..."
git clone --no-tags --branch=ttlang --single-branch \
    https://github.com/tsingletaryTT/freeciv.git freeciv
echo "TT-Lang: checked out $(git -C freeciv rev-parse --short HEAD) (ttlang branch)"
if test "$GIT_PATCHING" = "no" ; then
  # Remove .git so the checkout behaves like the original no-patching mode:
  # patches won't accidentally become commits and history won't be dragged in.
  rm -rf freeciv/.git
fi
