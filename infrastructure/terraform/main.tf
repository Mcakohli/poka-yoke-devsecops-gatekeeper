# ==============================================================================
# CANDIDATE DETAILS
# Full Name: Rahul Kohli
# Position: Junior Cloud & DevOps Engineer (GCP / Django / React)
# Document: Task 1 - Infrastructure-as-Code (Terraform Core Infrastructure)
# ==============================================================================

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# ------------------------------------------------------------------------------
# 1. Cloud Storage: DO Raw Landing Bucket
# ------------------------------------------------------------------------------
resource "google_storage_bucket" "raw_landing_bucket" {
  name                        = "${var.gcp_project_id}-do-raw-landing"
  location                    = var.gcp_region
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

resource "google_storage_bucket_iam_binding" "raw_landing_admin" {
  bucket = google_storage_bucket.raw_landing_bucket.name
  role   = "roles/storage.objectAdmin"

  members = [
    "serviceAccount:${var.pipeline_service_account}"
  ]
}

# ------------------------------------------------------------------------------
# 2. BigQuery Dataset: D1 Staged / Enforced
# ------------------------------------------------------------------------------
resource "google_bigquery_dataset" "staged_enforced_dataset" {
  dataset_id                  = "d1_staged_enforced"
  friendly_name               = "D1 Staged Enforced Dataset"
  description                 = "Enforced and validated staging dataset for downstream analytics."
  location                    = var.gcp_region
  default_table_expiration_ms = 31536000000 # 1 Year Retention

  access {
    role          = "OWNER"
    user_by_email = var.admin_email
  }

  access {
    role          = "WRITER"
    user_by_email = var.pipeline_service_account
  }
}

resource "google_bigquery_table" "student_onboarding_staged" {
  dataset_id          = google_bigquery_dataset.staged_enforced_dataset.dataset_id
  table_id            = "student_onboarding"
  deletion_protection = false

  schema = <<EOF
[
  {
    "name": "student_id",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "Unique identifier for the student."
  },
  {
    "name": "parent_email",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "Contact email of the primary parent/guardian."
  },
  {
    "name": "has_learning_disability_dcyn",
    "type": "INTEGER",
    "mode": "REQUIRED",
    "description": "Binary DCYN Indicator: 1 for Yes, 0 for No."
  },
  {
    "name": "requires_lsa_dcyn",
    "type": "INTEGER",
    "mode": "REQUIRED",
    "description": "Binary DCYN Indicator: 1 for Yes, 0 for No."
  },
  {
    "name": "created_at",
    "type": "TIMESTAMP",
    "mode": "REQUIRED",
    "description": "Record ingested timestamp."
  }
]
EOF
}

# ------------------------------------------------------------------------------
# 3. Security Policy: Role-Based Access on BigQuery Table
# ------------------------------------------------------------------------------
resource "google_bigquery_table_iam_binding" "lsa_coordinators_viewer" {
  dataset_id = google_bigquery_dataset.staged_enforced_dataset.dataset_id
  table_id   = google_bigquery_table.student_onboarding_staged.table_id
  role       = "roles/bigquery.dataViewer"

  members = [
    "group:${var.lsa_coordinators_group}"
  ]
}