# ==============================================================================
# Full Name: Rahul Kohli
# Position: Junior Cloud & DevOps Engineer (GCP / Django / React)
# Document: Task 3 - Serializer & DCYN Unit Test Suite
# ==============================================================================

import pytest
from backend.serializers import StudentOnboardingSerializer


def test_valid_onboarding_payload_conversion():
    """Verify that clear affirmative inputs map to integer 1."""
    payload = {
        "student_id": "STU-99201",
        "parent_email": "parent@example.com",
        "learning_disability_response": "Yes",
        "lsa_assistance_response": "Required",
    }
    serializer = StudentOnboardingSerializer(data=payload)
    assert serializer.is_valid(), serializer.errors

    validated_data = serializer.save()
    assert validated_data["has_learning_disability_dcyn"] == 1
    assert validated_data["requires_lsa_dcyn"] == 1


def test_valid_negative_payload_conversion():
    """Verify that negative inputs map to integer 0."""
    payload = {
        "student_id": "STU-99202",
        "parent_email": "parent2@example.com",
        "learning_disability_response": "No",
        "lsa_assistance_response": "None",
    }
    serializer = StudentOnboardingSerializer(data=payload)
    assert serializer.is_valid(), serializer.errors

    validated_data = serializer.save()
    assert validated_data["has_learning_disability_dcyn"] == 0
    assert validated_data["requires_lsa_dcyn"] == 0


def test_invalid_ambiguous_payload_fails():
    """Verify that ambiguous human inputs are blocked (Poka-Yoke principle)."""
    payload = {
        "student_id": "STU-99203",
        "parent_email": "parent3@example.com",
        "learning_disability_response": "Maybe",  # Ambiguous string
        "lsa_assistance_response": "No",
    }
    serializer = StudentOnboardingSerializer(data=payload)
    assert not serializer.is_valid()
    assert "learning_disability_response" in serializer.errors