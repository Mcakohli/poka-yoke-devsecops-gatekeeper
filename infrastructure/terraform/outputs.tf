# ==============================================================================
# CANDIDATE DETAILS
# Full Name: Rahul Kohli
# Position: Junior Cloud & DevOps Engineer (GCP / Django / React)
# Document: Task 1 - Infrastructure-as-Code (Terraform Outputs)
# ==============================================================================

output "raw_bucket_name" {
  value       = google_storage_bucket.raw_landing_bucket.name
  description = "Name of the raw landing GCS bucket"
}

output "bigquery_dataset_id" {
  value       = google_bigquery_dataset.staged_enforced_dataset.dataset_id
  description = "ID of the staged BigQuery dataset"
}

output "bigquery_table_id" {
  value       = google_bigquery_table.student_onboarding_staged.table_id
  description = "ID of the student onboarding BigQuery table"
}