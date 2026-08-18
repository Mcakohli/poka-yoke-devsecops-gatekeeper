from rest_framework import serializers
from .validators import convert_to_dcyn


class StudentOnboardingSerializer(serializers.Serializer):
    """
    Poka-Yoke Serializer for Student Onboarding payloads.
    Transforms freeform text responses into explicit binary DCYN integer flags.
    """
    student_id = serializers.CharField(max_length=50, required=True)
    parent_email = serializers.EmailField(required=True)

    learning_disability_response = serializers.CharField(write_only=True, required=True)
    lsa_assistance_response = serializers.CharField(write_only=True, required=True)

    has_learning_disability_dcyn = serializers.IntegerField(read_only=True)
    requires_lsa_dcyn = serializers.IntegerField(read_only=True)

    def validate(self, attrs):
        errors = {}
        try:
            attrs["has_learning_disability_dcyn"] = convert_to_dcyn(
                attrs.get("learning_disability_response"), "learning_disability_response"
            )
        except Exception as e:
            errors["learning_disability_response"] = str(e)

        try:
            attrs["requires_lsa_dcyn"] = convert_to_dcyn(
                attrs.get("lsa_assistance_response"), "lsa_assistance_response"
            )
        except Exception as e:
            errors["lsa_assistance_response"] = str(e)

        if errors:
            raise serializers.ValidationError(errors)

        return attrs

    def create(self, validated_data):
        return {
            "student_id": validated_data["student_id"],
            "parent_email": validated_data["parent_email"],
            "has_learning_disability_dcyn": validated_data["has_learning_disability_dcyn"],
            "requires_lsa_dcyn": validated_data["requires_lsa_dcyn"],
        }
