output "gcs_raw_landing_bucket_name" {
  description = "The name of the D0 Raw Landing storage bucket"
  value       = google_storage_bucket.d0_raw_landing.name
}

output "bigquery_dataset_id" {
  description = "The ID of the D1 Staged Enforced dataset"
  value       = google_bigquery_dataset.d1_staged_enforced.dataset_id
}

output "bigquery_table_id" {
  description = "The ID of the student onboarding table"
  value       = google_bigquery_table.student_onboarding_staged.table_id
}
