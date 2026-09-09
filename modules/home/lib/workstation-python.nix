# Shared Python package selector for Alex's workstation Python toolbox.
# Single source of truth: imported by modules/home/dev-toolchain.nix (to build
# the actual python3.withPackages derivation put in home.packages) and by
# modules/home/fish.nix (to build the identical derivation an interactive
# fish shell aliases `python3` to). Keeping this as one file means both call
# sites always agree on the exact same store path — never two different
# python3 derivations landing in the same Home Manager generation, which
# would collide on bin/python3.
#
# uv (see modules/home/dev-toolchain.nix) is Alex's primary per-project
# Python/venv manager; this withPackages toolbox is the general-purpose
# interpreter for ad hoc scripts and notebooks outside a uv-managed project.
ps: with ps; [
  numpy
  pandas
  polars
  pyarrow
  duckdb
  scipy
  scikit-learn
  statsmodels
  matplotlib
  plotly
  pillow
  opencv4
  pyvips
  pymupdf
  pypdf
  pdfplumber
  python-docx
  openpyxl
  python-pptx
  requests
  httpx
  aiohttp
  beautifulsoup4
  lxml
  selectolax
  trafilatura
  playwright
  selenium
  markdownify
  pydantic
  rich
  typer
  tenacity
  tqdm
  psutil
  ruff
  mypy
  pytest
  hypothesis
  coverage
  pytest-xdist
  nox
  tox
  pipdeptree
  ipython
  jupyter
  jupyterlab
  openai
  anthropic
  litellm
  tiktoken
  tokenizers
]
