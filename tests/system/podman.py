import subprocess
import uuid
from pathlib import Path

LABEL = "rsyslog-tftp-test"
CONFIG = Path(__file__).resolve().parents[1] / "config"


def podman(*arguments: str, check: bool = True) -> str:
    result = subprocess.run(
        ["podman", *arguments], capture_output=True, text=True, check=False
    )
    if check and result.returncode != 0:
        raise RuntimeError(f"podman {' '.join(arguments)} failed:\n{result.stderr}")
    return result.stdout.strip()


def running_containers() -> list[str]:
    return podman("ps", "--all", "--quiet", "--filter", f"label={LABEL}").splitlines()


def remove_containers() -> None:
    for container in running_containers():
        podman("rm", "--force", "--time", "1", container, check=False)


class Network:
    def __init__(self) -> None:
        self.name = f"{LABEL}-{uuid.uuid4().hex[:12]}"
        podman("network", "create", "--label", LABEL, self.name)

    def remove(self) -> None:
        podman("network", "rm", "--force", self.name, check=False)


class Container:
    def __init__(
        self,
        name: str,
        image: str,
        network: Network,
        config: str,
        publish: str | None = None,
    ) -> None:
        self.name = name
        arguments = [
            "run",
            "--detach",
            "--rm",
            "--replace",
            "--name",
            self.name,
            "--hostname",
            self.name,
            "--label",
            LABEL,
            "--network",
            network.name,
            "--volume",
            f"{CONFIG / config}:/etc/rsyslog.conf:ro,Z",
        ]
        if publish:
            arguments += ["--publish", publish]
        podman(*arguments, image)

    def read(self, path: str) -> list[str]:
        return podman("exec", self.name, "cat", path, check=False).splitlines()

    def port(self, container_port: int) -> int:
        return int(podman("port", self.name, str(container_port)).rsplit(":", 1)[1])

    def remove(self) -> None:
        podman("rm", "--force", "--time", "1", self.name, check=False)
