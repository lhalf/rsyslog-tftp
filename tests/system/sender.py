import socket

from .podman import Container, Network

SYSLOG_PORT = 10514


class Sender:
    def __init__(
        self, image: str, network: Network, config: str = "sender.conf"
    ) -> None:
        self.container = Container(
            "sender", image, network, config, publish=f"127.0.0.1::{SYSLOG_PORT}"
        )

    def send(self, messages: list[str]) -> None:
        with socket.create_connection(
            ("127.0.0.1", self.container.port(SYSLOG_PORT)), timeout=10
        ) as connection:
            for index, message in enumerate(messages):
                connection.sendall(
                    f"<13>Jan 22 12:34:56 testhost test[{index}]: {message}\n".encode()
                )

    def remove(self) -> None:
        self.container.remove()
