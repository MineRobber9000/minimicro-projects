# hackertyper

Ever wanted to look like a stereotypical hacker in one of those B-movies? You know the type; bashing keys on a keyboard as code magically flies onto the screen before they pause and confidently state: "I'm in."

Well, this is the Mini Micro project for you! On startup, it selects a random [Mini Micro library][] and lets you pretend to type it as you mash your keyboard.

[Mini Micro library]: https://github.com/JoeStrout/minimicro-sysdisk/tree/master/sys/lib

## To run

Mount as `usr2` and `run "/usr2/startup.ms"` (this project doesn't rely on any files outside of the sys disk, so you can just run it without needing to `cd` into `/usr2`).

## Notes

To tweak the number of characters that appear with each key press, change `charsPerKey`. The default of `3` is chosen to replicate [hackertyper.net](https://hackertyper.net).
