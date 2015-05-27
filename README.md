# mod-raspbian-ua-netinst
Custom changes to `debian-pi\raspbian-ua-netinst`.

Holds the custom files that I need to build my own image of `debian-pi\raspbian-ua-netinst`.

Requirements:
- A clone of the repository `debian-pi\raspbian-ua-netinst` is present in the
same directory as where this repository resides:

```
  .
  ..
  mod-raspbian-ua-netinst
  netinst.branch
  raspbian-ua-netinst
```
- The file `../netinst.branch` contains the branch to be used. E.g.:

```
  user@host:~/mod-raspbian-ua-netinst$ cat ../netinst.branch
  v1.0.x
  user@host:~/mod-raspbian-ua-netinst$
```
