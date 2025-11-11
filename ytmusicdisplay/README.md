# ytmusicdisplay

A display/controller for [Pear Desktop][], a program that extends YouTube Music to a native desktop experience. Utilizes the API plugin.

[Pear Desktop]: https://github.com/pear-devs/pear-desktop

## To run

Make sure Pear is running, the API server extension is enabled and set up. Edit `config.grfon` with the host, port, and API key (if applicable).

Mount this folder as `usr2` and `cd "/usr2"; run "startup"`. The program will load the background animation and fonts before activating.

## Notes

The background animation (`im_*.png`) is from an [old video texture loop][] created by [Alan "Hitthebongo" O.][]. He released the entire set (including HTB013, which is the one I used) into the public domain.

[old video texture loop]: https://archive.org/details/TextureLoopsCreatedWithAxogonMutator_727/HTB013.wmv
[Alan "Hitthebongo" O.]: https://sites.google.com/site/hitthebongo/about
