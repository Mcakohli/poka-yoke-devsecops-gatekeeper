# ==============================================================================
# CANDIDATE DETAILS
# Full Name: Rahul Kohli
# Position: Junior Cloud & DevOps Engineer (GCP / Django / React)
# Document: Task 1 - Infrastructure-as-Code (Terraform Variables)
# ==============================================================================

variable "gcp_project_id" {
  type        = string
  description = "The GCP Project ID"
  default     = "habot-staging-rahulkohli"
}

variable "gcp_region" {
  type        = string
  description = "GCP Region for resources"
  default     = "asia-south1"
}

variable "pipeline_service_account" {
  type        = string
  description = "Service account email for CI/CD pipeline"
  default     = "cicd-pipeline-sa@habot-staging-rahulkohli.iam.gserviceaccount.com"
}

variable "lsa_coordinators_group" {
  type        = string
  description = "Group email for LSA Coordinators (Row-Level Security)"
  default     = "lsa-coordinators@habotconnect.com"
}

variable "admin_email" {
  type        = string
  description = "Admin user email"
  default     = "rahulkohli@example.com"
}