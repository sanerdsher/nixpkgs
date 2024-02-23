{ lib
, buildPythonPackage
, fetchFromGitHub
, fetchpatch
, rustPlatform
, stdenv
, libiconv
, brotli
, hypothesis
, lz4
, memory-profiler
, numpy
, py
, pytest-benchmark
, pytestCheckHook
, python-snappy
, zstd
}:

buildPythonPackage rec {
  pname = "cramjam";
  version = "2.8.2";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "milesgranger";
    repo = "pyrus-cramjam";
    rev = "refs/tags/v${version}";
    hash = "sha256-BO35s7qOW4+l968I9qn9L1m2BtgRFNYUNlA7W1sctT8=";
  };

  sourceRoot = "source/cramjam-python";

  preBuild = ''
    cargo metadata --offline # https://github.com/NixOS/nixpkgs/issues/261412
    chmod +w ../ # used in build
  '';

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit src sourceRoot;
    hash = "sha256-br522gHEMIgwZ6h670DiFmwmZoA6snu8qjGILL95d1M=";
  };

  nativeBuildInputs = with rustPlatform; [
    cargoSetupHook
    maturinBuildHook
  ];

  buildInputs = lib.optional stdenv.isDarwin libiconv;

  nativeCheckInputs = [
    brotli
    hypothesis
    lz4
    memory-profiler
    numpy
    py
    pytest-benchmark
    pytestCheckHook
    python-snappy
    zstd
  ];

  disabledTestPaths = [
    "benchmarks/test_bench.py"
  ];

  pytestFlagsArray = [
    "--benchmark-disable"
  ];

  pythonImportsCheck = [
    "cramjam"
  ];

  meta = with lib; {
    description = "Thin Python bindings to de/compression algorithms in Rust";
    homepage = "https://github.com/milesgranger/pyrus-cramjam";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ veprbl ];
  };
}
