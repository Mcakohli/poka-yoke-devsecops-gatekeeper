variable "project_id" {
  type        = string
  description = "Google Cloud Platform Project ID"
  default     = "habot-onboarding-staging"
}

variable "region" {
  type        = string
  description = "GCP deployment region"
  default     = "us-central1"
}
