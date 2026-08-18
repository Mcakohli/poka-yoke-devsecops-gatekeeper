terraform {
  required_version = ">= 1.7.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.36.0, < 7.0.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# 1. D0 Raw Landing Storage Bucket (Task 1)
resource "google_storage_bucket" "d0_raw_landing" {
  name                        = "${var.project_id}-d0-raw-landing"
  location                    = var.region
  force_destroy               = false
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 90
    }
  }
}

# 2. D1 Staged / Enforced BigQuery Dataset (Task 1)
resource "google_bigquery_dataset" "d1_staged_enforced" {
  dataset_id                  = "d1_staged_enforced"
  friendly_name               = "D1 Staged Enforced Dataset"
  description                 = "Poka-Yoke enforced dataset for validated student onboarding payloads"
  location                    = var.region
  default_table_expiration_ms = 31536000000

  labels = {
    env       = "staging"
    pipeline  = "poka-yoke-gatekeeper"
    data_tier = "d1-enforced"
  }
}

# 3. Student Onboarding Enforced Table (D1 Staged)
resource "google_bigquery_table" "student_onboarding_staged" {
  dataset_id          = google_bigquery_dataset.d1_staged_enforced.dataset_id
  table_id            = "student_onboarding_enforced"
  deletion_protection = false

  schema = <<EOF
[
  {
    "name": "student_id",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "Unique identifier for the student"
  },
  {
    "name": "parent_email",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "Primary parent contact email"
  },
  {
    "name": "has_learning_disability_dcyn",
    "type": "INTEGER",
    "mode": "REQUIRED",
    "description": "Deterministic binary conversion (1 = Affirmative, 0 = Negative)"
  },
  {
    "name": "requires_lsa_dcyn",
    "type": "INTEGER",
    "mode": "REQUIRED",
    "description": "Deterministic binary conversion for LSA support (1 = Required, 0 = Not Required)"
  },
  {
    "name": "ingested_at",
    "type": "TIMESTAMP",
    "mode": "REQUIRED",
    "description": "Timestamp of schema validation and sink ingestion"
  }
]
EOF
}

# 4. IAM Conditions on Dataset (Least Privilege & RBAC)
resource "google_bigquery_dataset_iam_member" "conditional_analyst_access" {
  dataset_id = google_bigquery_dataset.d1_staged_enforced.dataset_id
  role       = "roles/bigquery.dataViewer"
  member     = "group:analytics-team@habotconnect.com"

  condition {
    title       = "business_hours_access_only"
    description = "Enforce read access strictly during business hours UTC"
    expression  = "request.time.getHours('UTC') >= 8 && request.time.getHours('UTC') <= 18"
  }
}

# 5. Native BigQuery Row-Level Security (Row Access Policy)
resource "google_bigquery_row_access_policy" "lsa_assistance_required_filter" {
  project          = var.project_id
  dataset_id       = google_bigquery_dataset.d1_staged_enforced.dataset_id
  table_id         = google_bigquery_table.student_onboarding_staged.table_id
  policy_id        = "lsa_assistance_required_only"
  filter_predicate = "requires_lsa_dcyn = 1"

  grantees = [
    "group:lsa-support-staff@habotconnect.com"
  ]
}
