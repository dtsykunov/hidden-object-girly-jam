#!/usr/bin/env bash

set -eux

find . -name '*.gd' | grep -v 'addons/' | xargs gdscript-formatter --safe --reorder-code
