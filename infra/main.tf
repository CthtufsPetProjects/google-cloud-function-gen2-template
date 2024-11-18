# Terraform configuration to deploy infrastructure for Google Cloud Function Gen2 and required resources

# Required Providers
provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_project_service" "firebase_api" {
  project = var.project_id
  service = "firebase.googleapis.com"
}

resource "google_project_service" "firestore_api" {
  project = var.project_id
  service = "firestore.googleapis.com"
}

resource "google_project_service" "cloudrun_api" {
  project = var.project_id
  service = "run.googleapis.com"
}

resource "google_project_service" "cloudfunctions_api" {
  project = var.project_id
  service = "cloudfunctions.googleapis.com"
}

resource "google_project_service" "eventarc_api" {
  project = var.project_id
  service = "eventarc.googleapis.com"
}

resource "google_project_service" "cloud_build_api" {
  project = var.project_id
  service = "cloudbuild.googleapis.com"
}

resource "google_project_service" "artifact_registry_api" {
  project = var.project_id
  service = "artifactregistry.googleapis.com"
}

resource "google_project_service" "cloud_scheduler_api" {
  project = var.project_id
  service = "cloudscheduler.googleapis.com"
}

# Включение Pub/Sub API
resource "google_project_service" "pubsub_api" {
  project = var.project_id
  service = "pubsub.googleapis.com"
}

# Включение Secret Manager API
resource "google_project_service" "secret_manager_api" {
  project = var.project_id
  service = "secretmanager.googleapis.com"
}

resource "google_project_service" "compute_engine_api" {
  project = var.project_id
  service = "compute.googleapis.com"
}

# Создание сервисного аккаунта для деплоя функций
resource "google_service_account" "gha_sa" {
  account_id   = "github-actions-sa"
  display_name = "GitHub Actions Service Account"
  depends_on = [
    google_project_service.cloudrun_api,
    google_project_service.secret_manager_api,
  ]
}

# Назначение ролей сервисному аккаунту для деплоя функций
resource "google_project_iam_member" "functions_deploy_roles" {
  for_each = toset([
    "roles/cloudfunctions.developer",
    "roles/iam.serviceAccountUser",
    "roles/run.admin",
    "roles/artifactregistry.writer",
  ])

  project = var.project_id
  member  = "serviceAccount:${google_service_account.gha_sa.email}"
  role    = each.value
}

# Создание сервисного аккаунта для доступа к Firebase
resource "google_service_account" "check_site_update_function_sa" {
  account_id   = "check-site-update-function"
  display_name = "Service Account for CheckSiteUpdates"
  depends_on = [
    google_project_service.firebase_api,
    google_project_service.firestore_api,
    google_project_service.cloudrun_api,
    google_project_service.secret_manager_api,
  ]
}

resource "google_project_iam_member" "cloud_build_artifact_registry_reader" {
  project = var.project_id
  role    = "roles/artifactregistry.admin"
  member  = "serviceAccount:${google_service_account.check_site_update_function_sa.email}"
}

# Назначение роли сервисному аккаунту для доступа к Firebase
resource "google_project_iam_member" "firebase_access_role" {
  project = var.project_id
  member  = "serviceAccount:${google_service_account.check_site_update_function_sa.email}"
  role    = "roles/firebase.admin"
}

# Назначение роли на чтение секретов для сервисного аккаунта csfu
resource "google_project_iam_member" "csfu_secret_reader" {
  project = var.project_id
  member  = "serviceAccount:${google_service_account.check_site_update_function_sa.email}"
  role    = "roles/secretmanager.secretAccessor"
}

# Assign logging permissions to the service account for Cloud Logging
resource "google_project_iam_member" "logging_permissions" {
  project = var.project_id
  member  = "serviceAccount:${google_service_account.check_site_update_function_sa.email}"
  role    = "roles/logging.logWriter"
}

# Google Secret Manager Secrets
resource "google_secret_manager_secret" "csfu_targets" {
  secret_id = "CSFU_TARGETS"
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
  depends_on = [
    google_project_service.secret_manager_api,
  ]
}
resource "google_secret_manager_secret_version" "target_url_version" {
  secret      = google_secret_manager_secret.csfu_targets.id
  secret_data = var.csfu_targets
  depends_on = [
    google_project_service.secret_manager_api,
  ]
}

resource "google_secret_manager_secret" "csfu_target_timeout" {
  secret_id = "CSFU_TARGET_TIMEOUT"
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
  depends_on = [
    google_project_service.secret_manager_api,
  ]
}
resource "google_secret_manager_secret_version" "csfu_target_timeout_version" {
  secret      = google_secret_manager_secret.csfu_target_timeout.id
  secret_data = var.csfu_target_timeout
  depends_on = [
    google_project_service.secret_manager_api,
  ]
}

resource "google_secret_manager_secret" "csfu_proxy" {
  secret_id = "CSFU_PROXY"
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
  depends_on = [
    google_project_service.secret_manager_api,
  ]
}
resource "google_secret_manager_secret_version" "csfu_proxy_version" {
  secret      = google_secret_manager_secret.csfu_proxy.id
  secret_data = var.csfu_proxy
  depends_on = [
    google_project_service.secret_manager_api,
  ]
}

resource "google_secret_manager_secret" "csfu_http_header_name" {
  secret_id = "CSFU_HTTP_HEADER_NAME"
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
  depends_on = [
    google_project_service.secret_manager_api,
  ]
}
resource "google_secret_manager_secret_version" "csfu_http_header_name_version" {
  secret      = google_secret_manager_secret.csfu_http_header_name.id
  secret_data = var.csfu_http_header_name
  depends_on = [
    google_project_service.secret_manager_api,
  ]
}

resource "google_secret_manager_secret" "csfu_http_header_value" {
  secret_id = "CSFU_HTTP_HEADER_VALUE"
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
  depends_on = [
    google_project_service.secret_manager_api,
  ]
}
resource "google_secret_manager_secret_version" "csfu_http_header_value_version" {
  secret      = google_secret_manager_secret.csfu_http_header_value.id
  secret_data = var.csfu_http_header_value
  depends_on = [
    google_project_service.secret_manager_api,
  ]
}

resource "google_secret_manager_secret" "csfu_webhook_url" {
  secret_id = "CSFU_WEBHOOK_URL"
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
  depends_on = [
    google_project_service.secret_manager_api,
  ]
}
resource "google_secret_manager_secret_version" "webhook_url_version" {
  secret      = google_secret_manager_secret.csfu_webhook_url.id
  secret_data = var.csfu_webhook_url
  depends_on = [
    google_project_service.secret_manager_api,
  ]
}

resource "google_secret_manager_secret" "csfu_webhook_secret_header" {
  secret_id = "CSFU_WEBHOOK_SECRET_HEADER"
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
  depends_on = [
    google_project_service.secret_manager_api,
  ]
}
resource "google_secret_manager_secret_version" "csfu_webhook_secret_header_version" {
  secret      = google_secret_manager_secret.csfu_webhook_secret_header.id
  secret_data = var.csfu_webhook_secret_header
  depends_on = [
    google_project_service.secret_manager_api,
  ]
}

resource "google_secret_manager_secret" "csfu_webhook_retry_attempts" {
  secret_id = "CSFU_WEBHOOK_RETRY_ATTEMPTS"
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
  depends_on = [
    google_project_service.secret_manager_api,
  ]
}
resource "google_secret_manager_secret_version" "csfu_webhook_retry_attempts_version" {
  secret      = google_secret_manager_secret.csfu_webhook_retry_attempts.id
  secret_data = var.csfu_webhook_retry_attempts
  depends_on = [
    google_project_service.secret_manager_api,
  ]
}

resource "google_secret_manager_secret" "csfu_webhook_retry_wait" {
  secret_id = "CSFU_WEBHOOK_RETRY_WAIT"
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
  depends_on = [
    google_project_service.secret_manager_api,
  ]
}
resource "google_secret_manager_secret_version" "csfu_webhook_retry_wait_version" {
  secret      = google_secret_manager_secret.csfu_webhook_retry_wait.id
  secret_data = var.csfu_webhook_retry_wait
  depends_on = [
    google_project_service.secret_manager_api,
  ]
}

resource "google_secret_manager_secret" "csfu_webhook_timeout" {
  secret_id = "CSFU_WEBHOOK_TIMEOUT"
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
  depends_on = [
    google_project_service.secret_manager_api,
  ]
}
resource "google_secret_manager_secret_version" "csfu_webhook_timeout_version" {
  secret      = google_secret_manager_secret.csfu_webhook_timeout.id
  secret_data = var.csfu_webhook_timeout
  depends_on = [
    google_project_service.secret_manager_api,
  ]
}

resource "google_secret_manager_secret" "db_timezone" {
  secret_id = "DB_TIMEZONE"
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
  depends_on = [
    google_project_service.secret_manager_api,
  ]
}
resource "google_secret_manager_secret_version" "db_timezone_version" {
  secret      = google_secret_manager_secret.db_timezone.id
  secret_data = var.db_timezone
  depends_on = [
    google_project_service.secret_manager_api,
  ]
}

resource "google_secret_manager_secret" "csfu_snapshots_keep_last_days" {
  secret_id = "CSFU_SNAPSHOTS_KEEP_LAST_DAYS"
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
  depends_on = [
    google_project_service.secret_manager_api,
  ]
}
resource "google_secret_manager_secret_version" "csfu_snapshots_keep_last_days_version" {
  secret      = google_secret_manager_secret.csfu_snapshots_keep_last_days.id
  secret_data = var.csfu_snapshots_keep_last_days
  depends_on = [
    google_project_service.secret_manager_api,
  ]
}

resource "google_secret_manager_secret" "events_pubsub_topic" {
  secret_id = "EVENTS_PUBSUB_TOPIC"
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
  depends_on = [
    google_project_service.secret_manager_api,
  ]
}
resource "google_secret_manager_secret_version" "events_pubsub_topic_version" {
  secret      = google_secret_manager_secret.events_pubsub_topic.id
  secret_data = var.events_pubsub_topic
  depends_on = [
    google_project_service.secret_manager_api,
  ]
}

resource "google_project_iam_member" "pubsub_publisher" {
  project = var.project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${google_service_account.check_site_update_function_sa.email}"
}

resource "google_firestore_database" "default" {
  name        = "(default)"
  project     = var.project_id
  location_id = var.region
  type        = "FIRESTORE_NATIVE"

  depends_on = [
    google_project_service.firestore_api,
  ]
}

# Firestore Index
resource "google_firestore_index" "website_content_index" {
  project       = var.project_id
  collection    = "website_content"  # This is a model in app/models.py
  query_scope   = "COLLECTION"

  fields {
    field_path = "url"
    order      = "ASCENDING"
  }

  fields {
    field_path = "timestamp"
    order      = "DESCENDING"
  }

  fields {
    field_path = "__name__"
    order      = "DESCENDING"
  }

  depends_on = [
    google_firestore_database.default,
  ]
}

# Google Pub/Sub Topic для триггера функции
resource "google_pubsub_topic" "hourly_trigger" {
  name = var.events_pubsub_topic

  depends_on = [
    google_project_service.pubsub_api,
  ]
}

# Google Cloud Scheduler Job для публикации сообщений в Pub/Sub топик
resource "google_cloud_scheduler_job" "hourly_job" {
  name      = "hourly-check-job"
  schedule  = "0 * * * *" # Каждый час
  time_zone = "UTC"

  pubsub_target {
    topic_name = google_pubsub_topic.hourly_trigger.id
    data       = base64encode("Hourly trigger for website check")
  }

  depends_on = [
    google_project_service.cloud_scheduler_api,
    google_project_service.pubsub_api,
    google_pubsub_topic.hourly_trigger,
  ]
}

# IAM Binding для разрешения Pub/Sub вызывать Cloud Functions через Eventarc
resource "google_cloud_run_service_iam_member" "pubsub_invoker" {
  location = var.region
  project  = var.project_id
  service  = "v1/projects/${var.project_id}/locations/${var.region}/services/${var.csfu_function_name}"
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.check_site_update_function_sa.email}"
}
