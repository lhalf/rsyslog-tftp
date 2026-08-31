import time

from .podman import Container, Network

RECEIVED_LOG = "/var/log/received.log"


class Receiver:
    def __init__(
        self, image: str, network: Network, config: str = "receiver.conf"
    ) -> None:
        self.container = Container("receiver", image, network, config)

    def received(self, count: int, timeout: int = 30) -> str:
        deadline = time.monotonic() + timeout
        lines: list[str] = []
        while time.monotonic() < deadline:
            lines = self.container.read(RECEIVED_LOG)
            if len(lines) >= count:
                break
            time.sleep(0.5)
        return "\n".join(lines)

    def remove(self) -> None:
        self.container.remove()
