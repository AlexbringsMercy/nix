{ pkgs, ... }:
# QA/security/supply-chain scanners, reverse-engineering/debug tools, and
# network recon tooling from Alex's workstation tooling plan. Split out from
# modules/home/dev-toolchain.nix so this more sensitive category (packet
# capture, port scanning, web fuzzing) is easy to review or drop on its own —
# it is still just CLI tooling on Alex's own machine, nothing here opens a
# network listener or runs unattended.
#
# tshark (wireshark-cli, below) needs non-root capture capability to be
# useful without sudo every time; that's granted at the system level in
# modules/nixos/dev-virtualisation.nix (programs.wireshark.enable + the
# `wireshark` group), not here.
{
  home.packages = with pkgs; [
    # -- QA / SECURITY / SUPPLY-CHAIN --
    semgrep
    gitleaks
    trufflehog
    osv-scanner
    trivy
    syft
    grype
    detect-secrets
    shellcheck
    shfmt
    hadolint
    actionlint
    markdownlint-cli2
    vale
    cspell
    typos
    yamllint
    yamlfmt
    editorconfig-checker
    cppcheck
    cosign
    crane
    oras
    skopeo
    dive
    lazydocker
    ctop
    act

    # -- RE / DEBUG --
    hexyl
    vim # provides `xxd`
    upx
    jadx
    apktool
    bpftrace
    radare2
    rizin
    binwalk
    yara
    # imhex, ilspycmd: skipped — see docs/tooling-notes.md.
    ghidra
    # frida-tools: deliberately deferred — install later with
    #   `uv tool install frida-tools`.

    # -- NETWORK RECON (the offensive-tooling half of the plan's NETWORK
    #    section; everyday network basics are in dev-toolchain.nix) --
    nmap
    wireshark-cli # tshark; see the capability note above
    mitmproxy
    sslscan
    testssl
    nuclei
    httpx # ProjectDiscovery's Go `httpx`, distinct from python's httpx library
    subfinder
    dnsx
    katana
    ffuf
    feroxbuster
    zap # OWASP ZAP; burpsuite is unfree+large and skipped, see notes
  ];
}
