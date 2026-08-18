# ==============================================================================
# Full Name: Rahul Kohli
# Position: Junior Cloud & DevOps Engineer (GCP / Django / React)
# Document: Task 3 - DCYN Binary Validation Logic Library
# ==============================================================================

from rest_framework.exceptions import ValidationError


def convert_to_dcyn(value: str, field_name: str) -> int:
    """
    DCYN (Deterministic Convert Yes/No) Library:
    Converts flexible form strings to deterministic 1 (Yes) or 0 (No).
    Raises ValidationError for ambiguous or unexpected inputs to eliminate
    human judgment and prevent schema mismatches in BigQuery sinks.
    """
    if not isinstance(value, str):
        raise ValidationError(f"Field '{field_name}' must be a string value.")

    cleaned_value = value.strip().lower()

    affirmative_patterns = {"yes", "true", "1", "y", "affirmative", "required"}
    negative_patterns = {"no", "false", "0", "n", "negative", "not required", "none"}

    if cleaned_value in affirmative_patterns:
        return 1
    elif cleaned_value in negative_patterns:
        return 0
    else:
        raise ValidationError(
            f"Ambiguous value '{value}' in field '{field_name}' cannot be deterministically mapped to binary DCYN logic."
        )