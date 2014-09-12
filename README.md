jlcmplayer
==========

JLCM Lightweight Children's Music Player

Project summary
---------------

A small, remote controlled music player for children.

Image you bring your kid(s) to bed and they want to hear a CD before they sleep. After ten minutes they call you because
the CD is boring and they want to hear another one. Or one CD finishes and they need the next one. And you keep running.

What if instead you could attach a small device to your stereo that contains all CDs as MP3s and that device could be
attached to the stereo. And the kids, even if only three years old could easily pick what they want to hear using an
old smartphone or tablet.

The device (a Raspberry Pi or similar) and the smartphone/table you have to find yourself. But the simple control 
software is here.

The idea is to remove all unnecessary clutter from typical media player software and just leave the bare minimum.
* Visual selection of a CD (music, audio book, etc)
* Play and pause

Leave out all the fancy features that media players usually have.
* No playlists
* No next track/previous track
* No seeking within a track
* No complex media library
* No shuffle/repeat
* Not even a stop button
* No security. You heard right. The player is intended to run in a home network and be used by 5-year-olds who can 
barely read. No need to be hacker-proof.

Technological considerations
----------------------------

The player must run on small devices with limited resources, usually ARM but sometimes maybe also x86.
* Player must be portable
* Must play at least MP3 and allow future extension (OGG, etc)
* Should be written in a language with lightweight runtime
* Use libraries with small footprint
* Frontend should work on various mobile platforms (Android, iOS, Windows, etc)
* Should be easy to install - ideally just unzip and run a script

I looked at Java first because I feel most comfortable there. Had a look at JLayer for media playback but it looked 
unnecessarily complex. I liked the JavaFX approach but when I tried to play an audio file on Ubuntu (on my PC!) it had
issues with the installed codec library.

Next I looked at NodeJS and the available libraries.
* With the modules 'speaker' and 'lame' I can playback MP3s easily
* I always liked the asynchronous programming model in node space
* Communication with client side will be almost seamless. Socket.IO, here I come
* NodeJS footprint is very small
* It is available on most of the relevant platforms

Some downsides I am willing to accept
* No official pre-built Node binaries on their homepage, have to rely on those shipped with Linux
* Latest Node sources do not build on ARM but I am confident that there will be a solution
* For distribution I would need to build various system specific NodeJS binaries for the various platforms (guys, you I
hope you can help out here...)

Project status
--------------

Just beginning.
