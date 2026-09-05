# ref: https://crftwr.github.io/keyhac/doc/config-api.html
from typing import Any, Callable, Literal, Protocol, TypeAlias

KeyCode: TypeAlias = int
KeyName: TypeAlias = str
Key: TypeAlias = str | int

Platform: TypeAlias = Literal["windows", "mac"]

class KeyTable:
    def __setitem__(
        self,
        key: str,
        action: Any,
    ) -> None: ...
    def __getitem__(
        self,
        key: str,
    ) -> Any: ...
    def __delitem__(
        self,
        key: str,
    ) -> None: ...
    def __contains__(
        self,
        key: str,
    ) -> bool: ...

class ClipboardHistory:
    persist: bool
    max_items: int

    def items(self) -> list[str]: ...
    def get_current(self) -> str | None: ...
    def set_current(self, index: int) -> None: ...

class InputContext:
    def __enter__(self) -> "InputContext": ...
    def __exit__(
        self,
        exc_type: type[BaseException] | None,
        exc_value: BaseException | None,
        traceback: Any,
    ) -> None: ...
    def send_key(self, key: str) -> None: ...
    def send_text(self, text: str) -> None: ...
    def send_mouse_move(
        self,
        dx: int,
        dy: int,
    ) -> None: ...

class Keymap:
    platform: Platform
    editor: str | Callable[[str], None]
    clipboard_history: ClipboardHistory

    @classmethod
    def get_instance(cls) -> "Keymap | None": ...
    def define_keytable(
        self,
        name: str | None = None,
        focus_path_pattern: str | None = None,
        custom_condition_func: Callable[[Any], bool] | None = None,
        app: str | None = None,
        title: str | None = None,
        class_name: str | None = None,
    ) -> KeyTable: ...
    def define_modifier(
        self,
        key: Key,
        mod: Key,
    ) -> None: ...
    def replace_key(
        self,
        src: Key,
        dst: Key,
    ) -> None: ...
    def get_input_context(
        self,
        replay: bool = False,
    ) -> InputContext: ...
    def edit_config(self) -> None: ...
    def reload_config(self) -> None: ...
    def find_window(
        self,
        app: str | None = None,
        title: str | None = None,
        class_name: str | None = None,
    ) -> Any | None: ...
    def get_active_window(self) -> Any | None: ...
    def list_windows(self) -> list[Any]: ...
    def configure(self) -> None: ...

class InputText:
    def __init__(
        self,
        text: str,
    ) -> None: ...

class MoveWindow:
    def __init__(
        self,
        x: int | None = None,
        y: int | None = None,
        direction: Literal["left", "right", "up", "down", ""] = "",
        distance: float = 10,
        window_edge: bool = False,
        screen_edge: bool = True,
    ) -> None: ...

class MouseMove:
    def __init__(
        self,
        dx: int,
        dy: int,
    ) -> None: ...

class MouseButtonDown:
    def __init__(
        self,
        button: Literal["left", "right", "middle"] = "left",
    ) -> None: ...

class MouseButtonUp:
    def __init__(
        self,
        button: Literal["left", "right", "middle"] = "left",
    ) -> None: ...

class MouseButtonClick:
    def __init__(
        self,
        button: Literal["left", "right", "middle"] = "left",
    ) -> None: ...

class StartRecordingKeys:
    def __init__(self) -> None: ...

class StopRecordingKeys:
    def __init__(self) -> None: ...

class ToggleRecordingKeys:
    def __init__(self) -> None: ...

class PlaybackRecordedKeys:
    def __init__(self) -> None: ...

class Logger(Protocol):
    def debug(
        self,
        message: str,
        *args: Any,
        **kwargs: Any,
    ) -> None: ...
    def info(
        self,
        message: str,
        *args: Any,
        **kwargs: Any,
    ) -> None: ...
    def warning(
        self,
        message: str,
        *args: Any,
        **kwargs: Any,
    ) -> None: ...
    def error(
        self,
        message: str,
        *args: Any,
        **kwargs: Any,
    ) -> None: ...
    def exception(
        self,
        message: str,
        *args: Any,
        **kwargs: Any,
    ) -> None: ...

def getLogger(name: str) -> Logger: ...
def configure(keymap: Keymap) -> None: ...
