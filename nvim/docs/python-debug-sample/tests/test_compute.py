from compute import summarize


def test_summarize_nested_loop() -> None:
    result = summarize([2, 4, 6])
    assert result == {"count": 3, "total": 27}
