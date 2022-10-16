locals {
  // Service account
  service_account_name   = lower(var.service_account_name)
  service_account_email  = "${local.service_account_name}@${var.project}.iam.gserviceaccount.com"
  service_account_member = "serviceAccount:${local.service_account_email}"

  // Storage
  bucket_name      = lower(var.bucket_name)
  temp_folder_name = lower(var.temp_folder_name)
  temp_location    = "gs://${local.bucket_name}/${local.temp_folder_name}"

  // Pub/Sub input
  topic_name            = lower(var.topic_name)
  topic_schema_gcs_path = lookup(var.topic_schema, "gcs_path", null)
  subscription_name     = lower(var.subscription_name)

  // BigQuery success output
  dataset_name = lower(var.dataset_name)
  table_name   = lower(var.table_name)

  // Storage failure output
  errors_bucket_name = lower(var.errors_bucket_name)
  // BigQuery failure output
  errors_dataset_name = lower(var.errors_dataset_name)
  errors_table_name   = lower(var.errors_table_name)
  // Pub/Sub failure output
  errors_topic_name        = lower(var.errors_topic_name)
  errors_subscription_name = lower(var.errors_subscription_name)

  // Dataflow job(s)
  job_name  = lower(var.job_name)
  jobs      = { for job in var.jobs : job.version => job if !job.flex }
  flex_jobs = { for job in var.jobs : job.version => job if job.flex }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Service Account for Dataflow Job
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
resource "google_service_account" "service_account" {
  count = var.create_service_account ? 1 : 0

  account_id   = local.service_account_name
  display_name = local.service_account_name
  description  = var.service_account_description
  project      = var.project
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Storage for Dataflow files
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Create bucket
resource "google_storage_bucket" "bucket" {
  count = var.create_bucket ? 1 : 0

  name     = local.bucket_name
  project  = var.project
  location = var.location
  labels   = var.labels

  uniform_bucket_level_access = true
}

// Assign object admin role on bucket
resource "google_storage_bucket_iam_member" "bucket_role" {
  count = var.create_roles ? 1 : 0

  bucket = local.bucket_name
  role   = "roles/storage.objectAdmin"
  member = local.service_account_member

  depends_on = [
    google_service_account.service_account,
    google_storage_bucket.bucket
  ]
}

// Create folder for Dataflow temp files
resource "google_storage_bucket_object" "temp_folder" {
  count = var.create_bucket ? 1 : 0

  name    = "${local.temp_folder_name}/"
  bucket  = local.bucket_name
  content = "FOLDER"

  depends_on = [google_storage_bucket.bucket]
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Pub/Sub input
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Create Pub/Sub topic schema
resource "google_pubsub_schema" "topic_schema" {
  count = var.create_topic && var.topic_schema != null ? 1 : 0

  name       = local.topic_name
  project    = var.project
  type       = var.topic_schema.type
  definition = var.topic_schema.definition
}

// Create Pub/Sub topic
resource "google_pubsub_topic" "topic" {
  count = var.create_topic ? 1 : 0

  name    = local.topic_name
  project = var.project
  labels  = var.labels

  dynamic "schema_settings" {
    for_each = var.topic_schema != null ? [var.topic_schema] : []

    content {
      schema   = google_pubsub_schema.topic_schema[0].id
      encoding = var.topic_schema.encoding
    }
  }
}

// Upload Pub/Sub topic schema to Storage
resource "google_storage_bucket_object" "topic_schema" {
  count = local.topic_schema_gcs_path != null ? 1 : 0

  name    = local.topic_schema_gcs_path
  bucket  = local.bucket_name
  content = var.topic_schema.definition

  depends_on = [google_storage_bucket.bucket]
}

// Create Pub/Sub subscription
resource "google_pubsub_subscription" "subscription" {
  count = var.create_subscription ? 1 : 0

  name    = local.subscription_name
  topic   = local.topic_name
  project = var.project
  labels  = var.labels

  ack_deadline_seconds  = 60
  retain_acked_messages = true

  expiration_policy {
    ttl = ""
  }

  depends_on = [google_pubsub_topic.topic]
}

// Assign subcriber and viewer roles on subscription
resource "google_pubsub_subscription_iam_member" "subscription_roles" {
  for_each = var.create_roles ? toset(["subscriber", "viewer"]) : []

  subscription = local.subscription_name
  project      = var.project
  role         = "roles/pubsub.${each.key}"
  member       = local.service_account_member

  depends_on = [
    google_service_account.service_account,
    google_pubsub_subscription.subscription
  ]
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// BigQuery success output
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Create dataset
resource "google_bigquery_dataset" "dataset" {
  count = var.create_dataset ? 1 : 0

  dataset_id                 = local.dataset_name
  description                = var.dataset_description
  project                    = var.project
  friendly_name              = var.dataset_name
  location                   = var.location
  labels                     = var.labels
  delete_contents_on_destroy = true
}

// Assign data editor role on dataset
resource "google_bigquery_dataset_iam_member" "dataset_role" {
  count = var.create_roles ? 1 : 0

  dataset_id = local.dataset_name
  project    = var.project
  role       = "roles/bigquery.dataEditor"
  member     = local.service_account_member

  depends_on = [
    google_service_account.service_account,
    google_bigquery_dataset.dataset
  ]
}

// Create table
resource "google_bigquery_table" "table" {
  count = var.create_table ? 1 : 0

  dataset_id          = local.dataset_name
  table_id            = local.table_name
  schema              = var.table_schema
  description         = var.table_description
  project             = var.project
  friendly_name       = var.table_name
  labels              = var.labels
  deletion_protection = false

  time_partitioning {
    type = "DAY"
  }

  depends_on = [google_bigquery_dataset.dataset]
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Storage failure output
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Create bucket for Dataflow errors
resource "google_storage_bucket" "errors_bucket" {
  count = var.use_errors_bucket && var.create_errors_bucket ? 1 : 0

  name     = local.errors_bucket_name
  project  = var.project
  location = var.location
  labels   = var.labels

  uniform_bucket_level_access = true
}

// Assign object admin roles on bucket
resource "google_storage_bucket_iam_member" "errors_bucket_role" {
  count = var.use_errors_bucket && var.create_roles ? 1 : 0

  bucket = local.errors_bucket_name
  role   = "roles/storage.objectAdmin"
  member = local.service_account_member

  depends_on = [
    google_service_account.service_account,
    google_storage_bucket.errors_bucket
  ]
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// BigQuery failure output
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Create dataset for Dataflow errors
resource "google_bigquery_dataset" "errors_dataset" {
  count = var.use_errors_dataset && var.create_errors_dataset ? 1 : 0

  dataset_id                 = local.errors_dataset_name
  description                = var.errors_dataset_description
  project                    = var.project
  friendly_name              = var.errors_dataset_name
  location                   = var.location
  labels                     = var.labels
  delete_contents_on_destroy = true
}

// Assign data editor role on dataset
resource "google_bigquery_dataset_iam_member" "errors_dataset_role" {
  count = var.use_errors_dataset && var.create_roles ? 1 : 0

  dataset_id = local.errors_dataset_name
  project    = var.project
  role       = "roles/bigquery.dataEditor"
  member     = local.service_account_member

  depends_on = [
    google_service_account.service_account,
    google_bigquery_dataset.errors_dataset
  ]
}

// Create table for Dataflow errors
resource "google_bigquery_table" "errors_table" {
  count = var.use_errors_dataset && var.create_errors_table ? 1 : 0

  dataset_id          = local.errors_dataset_name
  table_id            = local.errors_table_name
  description         = var.errors_table_description
  project             = var.project
  friendly_name       = var.errors_table_name
  labels              = var.labels
  deletion_protection = false

  time_partitioning {
    type = "DAY"
  }

  depends_on = [google_bigquery_dataset.errors_dataset]
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Pub/Sub failure output
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Create topic for Dataflow errors
resource "google_pubsub_topic" "errors_topic" {
  count = var.use_errors_topic && var.create_errors_topic ? 1 : 0

  name    = local.errors_topic_name
  project = var.project
  labels  = var.labels
}

// Assign publisher role on topic
resource "google_pubsub_topic_iam_member" "errors_topic_role" {
  count = var.use_errors_topic && var.create_roles ? 1 : 0

  topic   = local.errors_topic_name
  project = var.project
  role    = "roles/pubsub.publisher"
  member  = local.service_account_member

  depends_on = [
    google_service_account.service_account,
    google_pubsub_topic.errors_topic
  ]
}

// Create subscription for Dataflow errors
resource "google_pubsub_subscription" "errors_subscription" {
  count = var.use_errors_topic && var.create_errors_subscription ? 1 : 0

  name    = local.errors_subscription_name
  topic   = local.errors_topic_name
  project = var.project
  labels  = var.labels

  ack_deadline_seconds  = 60
  retain_acked_messages = true

  expiration_policy {
    ttl = ""
  }

  depends_on = [google_pubsub_topic.errors_topic]
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Dataflow Job(s)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Assign dataflow worker role on project
resource "google_project_iam_member" "dataflow_role" {
  count = var.create_roles ? 1 : 0

  project = var.project
  role    = "roles/dataflow.worker"
  member  = local.service_account_member

  depends_on = [google_service_account.service_account]
}

// Create Dataflow job(s)
resource "google_dataflow_job" "jobs" {
  for_each = local.jobs

  name                  = "${local.job_name}-v${each.value.version}"
  project               = var.project
  region                = var.region
  labels                = var.labels
  template_gcs_path     = each.value.path
  temp_gcs_location     = local.temp_location
  service_account_email = local.service_account_email
  on_delete             = "drain"
  machine_type          = var.machine_type
  max_workers           = var.max_workers
  parameters            = each.value.parameters

  depends_on = [
    google_service_account.service_account,

    google_storage_bucket.bucket,
    google_storage_bucket_iam_member.bucket_role,
    google_storage_bucket_object.temp_folder,

    google_storage_bucket_object.topic_schema,
    google_pubsub_topic.topic,
    google_pubsub_subscription.subscription,
    google_pubsub_subscription_iam_member.subscription_roles,

    google_bigquery_dataset.dataset,
    google_bigquery_dataset_iam_member.dataset_role,
    google_bigquery_table.table,

    google_storage_bucket.errors_bucket,
    google_storage_bucket_iam_member.errors_bucket_role,

    google_bigquery_dataset.errors_dataset,
    google_bigquery_dataset_iam_member.errors_dataset_role,
    google_bigquery_table.errors_table,

    google_pubsub_topic.errors_topic,
    google_pubsub_topic_iam_member.errors_topic_role,
    google_pubsub_subscription.errors_subscription,

    google_project_iam_member.dataflow_role
  ]
}

// Create Dataflow Flex job(s)
resource "google_dataflow_flex_template_job" "flex_jobs" {
  provider = google-beta
  for_each = local.flex_jobs

  name                    = "${local.job_name}-v${each.value.version}"
  project                 = var.project
  region                  = var.region
  labels                  = var.labels
  container_spec_gcs_path = each.value.path
  on_delete               = "drain"

  parameters = merge({
    workerMachineType = var.machine_type
    maxNumWorker      = var.max_workers
    serviceAccount    = local.service_account_email
    tempLocation      = local.temp_location
  }, each.value.parameters)

  depends_on = [
    google_service_account.service_account,

    google_storage_bucket.bucket,
    google_storage_bucket_iam_member.bucket_role,
    google_storage_bucket_object.temp_folder,

    google_storage_bucket_object.topic_schema,
    google_pubsub_topic.topic,
    google_pubsub_subscription.subscription,
    google_pubsub_subscription_iam_member.subscription_roles,

    google_bigquery_dataset.dataset,
    google_bigquery_dataset_iam_member.dataset_role,
    google_bigquery_table.table,

    google_storage_bucket.errors_bucket,
    google_storage_bucket_iam_member.errors_bucket_role,

    google_bigquery_dataset.errors_dataset,
    google_bigquery_dataset_iam_member.errors_dataset_role,
    google_bigquery_table.errors_table,

    google_pubsub_topic.errors_topic,
    google_pubsub_topic_iam_member.errors_topic_role,
    google_pubsub_subscription.errors_subscription,

    google_project_iam_member.dataflow_role
  ]
}
