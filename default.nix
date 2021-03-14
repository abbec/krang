let
  sources = import ./nix/sources.nix;
  nixpkgs = with
    {
      overlay = _: pkgs:
        {
          niv = (import sources.niv { }).niv;
        };
    };
    import sources.nixpkgs
      {
        overlays = [ overlay (import sources.rust) ];
        config = { };
      };

  rustBin = (nixpkgs.rust-bin.stable."1.50.0".rust.override {
    targets = [ "wasm32-wasi" ];
  });

  # rust-analyzer cannot handle symlinks
  # so we need to create a derivation with the
  # correct rust source without symlinks
  rustSrcNoSymlinks = nixpkgs.stdenv.mkDerivation {
    name = "rust-src-no-symlinks";

    rustWithSrc = (rustBin.override {
      extensions = [ "rust-src" ];
    });
    rust = rustBin;

    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      mkdir -p $out
      cp -r -L $rustWithSrc/lib/rustlib/src/rust/library/. $out/
      '';
  };

  commonAttrs = {
    name = "krang";
    src = nixpkgs.nix-gitignore.gitignoreSource [] ./.;
    nativeBuildInputs = [ rustBin nixpkgs.cacert ];
    buildInputs =
      # this is needed since https://github.com/rust-lang/libc/commit/3e4d684dcdd1dff363a45c70c914204013810155
      # on macos
      nixpkgs.stdenv.lib.optional nixpkgs.stdenv.hostPlatform.isDarwin nixpkgs.libiconv;

    configurePhase = ''
      export CARGO_HOME=$PWD
    '';

    buildPhase = ''
      cargo build --release
    '';

    checkPhase = ''
      cargo fmt -- --check
      cargo clippy
      cargo test
    '';

    doCheck = true;

    installPhase = ''
      mkdir -p $out/bin
      find target/release -executable -type f -exec cp {} $out/bin \;
    '';

    shellHook = ''
      export RUST_SRC_PATH=${rustSrcNoSymlinks}
    '';

    RUSTFLAGS = "-D warnings";
    CARGO_TARGET_WASM32_WASI_RUNNER = "${nixpkgs.wasmtime}/bin/wasmtime";
  };
in
{
  host = nixpkgs.stdenv.mkDerivation commonAttrs;
  wasi = nixpkgs.stdenv.mkDerivation (commonAttrs // {
    CARGO_BUILD_TARGET = "wasm32-wasi";
  });
}
