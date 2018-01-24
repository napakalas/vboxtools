# -*- coding: utf-8 -*-
"""
Keyboard to scancode mapping for US keyboard layout.
"""

from itertools import chain

keys_base = (
    '`1234567890-='
    'qwertyuiop[]\\'
    'asdfghjkl;\''
    'zxcvbnm,./ \n'
)

keys_shift = (
    '~!@#$%^&*()_+'
    'QWERTYUIOP{}|'
    'ASDFGHJKL:"'
    'ZXCVBNM<>?'
)

# not using `bytes`, manual conversion with ord for python 2/3 compat
scancode_down_base = (
    '\x29\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d'
    '\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1a\x1b\x2b'
    '\x1e\x1f\x20\x21\x22\x23\x24\x25\x26\x27\x28'
    '\x2c\x2d\x2e\x2f\x30\x31\x32\x33\x34\x35\x39\x1c'
)

LSHIFT = '\x2a'

key_scancode_map = {}

# initial scancode
for key, init_scancode in zip(keys_base, scancode_down_base):
    key_scancode_map[key] = (
        ord(init_scancode),
        ord(init_scancode) + 0x80,
    )

# for the ones with shift
for key, init_scancode in zip(keys_shift, scancode_down_base):
    key_scancode_map[key] = (
        ord(LSHIFT), ord(init_scancode),
        ord(init_scancode) + 0x80, ord(LSHIFT) + 0x80,
    )


def keyboardputscancode(chars):
    """
    Return a space separated list of scancodes in hexadecimal numbers
    from the characters provided by chars.  Naturally, only characters
    in the mapping are supported.
    """

    return ' '.join('%02x' % i for i in chain(
        *(key_scancode_map[c] for c in chars)))


def main():
    """
    Make use of the keyboardputscancode function to provide a quick way
    to get commands inputed into a VirtualBox vm through the controlvm
    keyboardputscancode feature.  Example usage:

    VBoxManage controlvm $VBOX_NAME keyboardputscancode \
        $(echo whoami | python scancode.py)

    If the raw console was activated, whoami will be executed.

    Do note that there may be limitations in place with how long the
    command may be inputed at once.  If a sufficiently long command is
    required, break them up into multiple commands.  For example:

        VBoxManage controlvm $VBOX_NAME keyboardputscancode \
            $(echo -n '/etc/init.d/apache ' | python scancode.py)
        VBoxManage controlvm $VBOX_NAME keyboardputscancode \
            $(echo restart | python scancode.py)

    Note the -n flag for the first echo command to avoid sending a
    newline character through to the console.
    """

    import sys
    sys.stdout.write(keyboardputscancode(sys.stdin.read()))


if __name__ == '__main__':
    main()
