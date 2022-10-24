{ lib
, fetchFromGitHub
, installShellFiles
, makeWrapper
, buildGoModule
, fetchYarnDeps
, fixup_yarn_lock
, pkg-config
, nodejs
, yarn
, nodePackages
, python3
, terraform
}:

buildGoModule rec {
  pname = "coder";
  version = "0.16.0";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = "v${version}";
    hash = "sha256-3rGpyJzGkZYUEvKKDzj2I5sqrUImmmX7cXWM9UClPLY=";
  };

  offlineCache = fetchYarnDeps {
    yarnLock = src + "/site/yarn.lock";
    hash = "sha256-4GbM7GNZ3wHIZJIJuHw1v/SwjUNc1vi8IHRGaGwPGZQ=";
  };

  subPackages = [ "cmd/..." ];

  vendorHash = "sha256-bb9jBno7elO6qKGjacpX3rxgrpJpGpTxMQtdBYjBzMk=";

  # integration tests require network access
  doCheck = false;

  ldflags = [
    "-s"
    "-w"
    "-X github.com/coder/coder/buildinfo.tag=${version}"
  ];

  preBuild = ''
    export HOME=$TEMPDIR

    pushd site
    yarn config --offline set yarn-offline-mirror ${offlineCache}
    fixup_yarn_lock yarn.lock

    # node-gyp tries to download always the headers and fails: https://github.com/NixOS/nixpkgs/issues/195404
    yarn remove --offline jest-canvas-mock canvas

    NODE_ENV=production node node_modules/.bin/vite build

    popd
  '';

  tags = [ "embed" ];

  nativeBuildInputs = [
    fixup_yarn_lock
    installShellFiles
    makeWrapper
    nodePackages.node-pre-gyp
    nodejs
    pkg-config
    python3
    yarn
  ];

  postInstall = ''
    installShellCompletion --cmd coder \
      --bash <($out/bin/coder completion bash) \
      --fish <($out/bin/coder completion fish) \
      --zsh <($out/bin/coder completion zsh)

    wrapProgram $out/bin/coder --prefix PATH : ${lib.makeBinPath [ terraform ]}
  '';

  meta = with lib; {
    description = "Provision software development environments via Terraform on Linux, macOS, Windows, X86, ARM, and of course, Kubernetes";
    homepage = "https://coder.com";
    license = licenses.agpl3;
    maintainers = with maintainers; [ ghuntley urandom ];
  };
}
