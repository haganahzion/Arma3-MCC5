import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from balance_check import balance, strip_code  # noqa: E402


def test_balanced_code():
    assert balance('if (true) then {[1,2] call f};') == (0, 0, 0)


def test_counts_unbalanced():
    assert balance("[[{(") == (2, 1, 1)
    assert balance("]})") == (-1, -1, -1)


def test_ignores_line_and_block_comments():
    assert balance("a = 1; // [[[ {{\n/* ((( */ b = 2;") == (0, 0, 0)


def test_ignores_strings_with_escaped_quotes():
    assert balance('hint "a ""[["" b {";') == (0, 0, 0)


def test_single_quotes_are_counted():
    # single-quoted strings are not stripped, matching the DEVNOTES rule
    assert balance("x = '[';") == (1, 0, 0)


def test_unterminated_string_and_comment_do_not_crash():
    assert balance('x = "[[[') == (0, 0, 0)
    assert balance("x = 1; /* [[[") == (0, 0, 0)


def test_empty_and_binary_noise():
    assert balance("") == (0, 0, 0)
    assert strip_code("\x00\x01//\x02") == "\x00\x01"


def test_slash_alone_is_kept():
    assert strip_code("a / b") == "a / b"
