#!/bin/sh

# Keyboard remapping
cat <<KEYMAPPINGS | xmodmap -
! Muhenkan -> Escape
keycode 102 = Escape
! Henkan -> Return
keycode 100 = Return
! Hiragana_Katakana -> BackSpace
keycode 101 = BackSpace
! backslash -> underscore
keycode 97 = underscore underscore
KEYMAPPINGS

# No key repeat
xset -r 49  # HHK Hankaku_Zenkaku
xset -r 101 # HHK Hiragana_Katakana
xset -r 22  # HHK modifiered BackSpace
