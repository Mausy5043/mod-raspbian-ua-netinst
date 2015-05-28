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
- The file `../netinst.branch` contains the name of the branch to be used. E.g.:

```
  user@host:~/mod-raspbian-ua-netinst$ cat ../netinst.branch
  v1.0.x
  user@host:~/mod-raspbian-ua-netinst$
```

## Installing
1. Clone `debian-pi\raspbian-ua-netinst`
2. Clone `Mausy5043\mod-raspbian-ua-netinst`
3. `echo "v1.0.x" > netinst.branch   # this defines the branch to be used`

## Usage
1. `cd mod-raspbian-ua-netinst`
2. `mod-ua.sh <hostname>`
3. the rest is automatic:
  - The repos are updated to the current version and the chosen branch is selected.
  - Files contained in the directory `overlay` are copied to the raspbian-ua-netinst directory.
  - The raspbian-ua-netinst image is built by executing the `clean.sh`, `update.sh` and `build.sh`.
  - Attention: If `buildroot.sh` is required, then this needs to be done manually.
