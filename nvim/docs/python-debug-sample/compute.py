def summarize(values: list[int]) -> dict[str, int]:
    def adjusted(value: int) -> int:
        return value * 2 + 1

    total = 0
    transformed = []
    for item in values:
        result = adjusted(item)
        transformed.append(result)
        total += result
    return {"count": len(transformed), "total": total}


if __name__ == "__main__":
    print(summarize([2, 4, 6]))
