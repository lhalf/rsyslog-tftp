import platform
from pathlib import Path

from .podman import LABEL, podman

REPO = Path(__file__).resolve().parents[2]
TESTS = Path(__file__).resolve().parents[1]

ARCHITECTURES = {
    "deb": {"x86_64": "amd64", "aarch64": "arm64"},
    "rpm": {"x86_64": "x86_64", "aarch64": "aarch64"},
}


def build(packager: str) -> str:
    tag = f"{LABEL}-{packager}"
    podman(
        "build",
        "--file",
        str(TESTS / f"{packager}.dockerfile"),
        "--build-arg",
        f"PACKAGE={package(packager)}",
        "--tag",
        tag,
        str(REPO),
    )
    return tag


def package(packager: str) -> str:
    architecture = ARCHITECTURES[packager][platform.machine()]
    packages = list((REPO / "build").glob(f"*{architecture}.{packager}"))
    if not packages:
        raise RuntimeError(
            f"no {architecture} {packager} in build, run just package first"
        )
    return str(packages[0].relative_to(REPO))
