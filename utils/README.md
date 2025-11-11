# utils

A handful of utilities that I've written which can be used in other projects.

 - `base64.ms`: Base64 encoding/decoding. Comes with a set of different base64 alphabets.
 - `function_iter.ms` and `iterator.ms`: "Iterator" paradigms (`x = Iterator.make([args]); while x.hasNext; val = x.next; end while`).
 - `keyviewer.ms`: Prints the return value of `key.get` for whatever keys you press (and the unicode codepoint for those values).
 - `startup.ms`: Defines some aliases and specialty commands for use in the Mini Micro console.
 - `unidecode.ms`: Replaces certain characters that aren't in the Mini Micro default font with characters that are.
