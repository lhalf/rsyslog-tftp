import pytest

from system.podman import remove_containers, running_containers


def pytest_sessionstart(session: pytest.Session) -> None:
    remove_containers()


def pytest_sessionfinish(session: pytest.Session, exitstatus: int) -> None:
    remove_containers()
    if running_containers():
        session.exitstatus = 1
        print("containers outlived the test session")
