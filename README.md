My 3D experiments
=================

This work is licensed under the
[Creative Commons Attribution-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-sa/4.0/).


Repository setup
----------------

Setup of this repository follows this [article](https://blog.lambda.cx/posts/freecad-and-git/).

In short, following must be done:

1. Install [Zippey](https://bitbucket.org/sippey/zippey/src/master/)
2. `git config [--global] filter.zippey.smudge "$PATH_TO/zippey.py d"`
3. `git config [--global] filter.zippey.clean "$PATH_TO/zippey.py e"`
4. Add the following to your `gitconfig`:

```
[diff "zip"]
textconv = unzip -c -a
[core]
attributesfile = ~/.gitattributes
```

5. And the following to `~/.gitattributes`

```
*.FCStd filter=zippey
*.FCStd diff=zip
```
