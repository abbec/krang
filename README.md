# Krang

Krang is a Scheme R7RS interpreter with a focus on minimalism, portability and embedding use-cases.

## Developer Setup

Krang uses [Nix](https://nixos.org) for dependency management. Install nix if you havent already
and then you can build Krang with

```
$ nix build
```

This will build Krang for both the host platform and for WASI (a primary target of this project).

To only build it for the host platform

```
$ nix build -f default.nix host
```

And for WASI

```
$ nix build -f default.nix wasi
```

To get a development shell for the host or WASI

```
$ nix-shell -A wasi/host
```
