from system import image
from system.podman import Network, running_containers
from system.receiver import Receiver
from system.sender import Sender


class EndToEndTests:
    packager = ""
    sender_config = "sender.conf"
    receiver_config = "receiver.conf"

    sender_image: str
    receiver_image: str

    @classmethod
    def setup_class(cls) -> None:
        cls.sender_image = image.build(cls.packager)
        cls.receiver_image = image.build("rpm")

    def setup_method(self) -> None:
        self.network = Network()
        self.receiver = Receiver(
            self.receiver_image, self.network, self.receiver_config
        )
        self.sender = Sender(self.sender_image, self.network, self.sender_config)

    def teardown_method(self) -> None:
        self.sender.remove()
        self.receiver.remove()
        self.network.remove()
        assert not running_containers(), "containers outlived the test"

    def test_single_message_is_delivered(self) -> None:
        self.sender.send(["a single message"])

        assert "a single message" in self.receiver.received(1)

    def test_batch_of_messages_is_delivered(self) -> None:
        messages = [f"message {index}" for index in range(50)]

        self.sender.send(messages)

        received = self.receiver.received(len(messages))
        assert all(message in received for message in messages)


class TestDeb(EndToEndTests):
    packager = "deb"


class TestRpm(EndToEndTests):
    packager = "rpm"


class TestDebSinglePort(EndToEndTests):
    packager = "deb"
    sender_config = "sender-single-port.conf"
    receiver_config = "receiver-single-port.conf"


class TestRpmSinglePort(EndToEndTests):
    packager = "rpm"
    sender_config = "sender-single-port.conf"
    receiver_config = "receiver-single-port.conf"
