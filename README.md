# Raclette

This is something I'm writing for myself for a very specific purpose: to
retrieve audio from YouTube videos, derive useful information from the
metadata, and produce m4a/aac audio files that are tagged and can be
imported into iTunes.

# Why?

There's a wealth of classical music on YouTube and I want to listen to it
offline.  I don't feel like downloading all of these files and tagging them
myself; it seemed like a fun one-day-project to glue together some really
great tools to get it to do what I need.

# And?

Well, it's not designed to be open-ended and flexible; it's just
designed to do one job.  This means the code is pretty grim.

# Installation

This will only work on OSX, as far as I know.  I suppose it could work
on Linux with some tweaking, but Windoze is probably a lost cause.

Check it out of github:

    git clone https://github.com/quile/raclette.git

Make sure you have these dependencies installed:

    brew install youtube-dl
    brew install ffmpeg --with-faac
    brew install mp4v2

and if you need it,

    brew install cpanm

and obviously Perl, too, which should be installed already.

Perl requires these dependencies (one of these days I'll make
a Makefile.PL for them):

```bash
> cpanm JSON
```

# Usage

Basic usage:

```bash
> cd raclette/
> perl -Ilib bin/raclette --input=<youtube id of video or playlist> --output=<dir> [--skip-download=X] [--override key=value]
```
