from rest_framework.exceptions import ValidationError

AFFIRMATIVE_RESPONSES = {
    "yes",
    "y",
    "true",
    "1",
    "required",
    "needed",
    "affirmative",
    "positive",
}

NEGATIVE_RESPONSES = {
    "no",
    "n",
    "false",
    "0",
    "none",
    "not required",
    "not needed",
    "negative",
}


def convert_to_dcyn(value: str, field_name: str) -> int:
    """
    Transforms loose human responses into deterministic binary DCYN values (1 or 0).
    Blocks ambiguous strings to maintain downstream BigQuery integrity.
    """
    if value is None:
        raise ValidationError(f"Field '{field_name}' cannot be null.")

    normalized = str(value).strip().lower()

    if normalized in AFFIRMATIVE_RESPONSES:
        return 1
    elif normalized in NEGATIVE_RESPONSES:
        return 0

    msg = (
        f"Ambiguous value '{value}' in field '{field_name}' cannot be "
        "deterministically mapped to binary DCYN logic."
    )
    raise ValidationError(msg)
