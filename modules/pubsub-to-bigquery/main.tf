locals {
  job_parameters = {
    inputSubscription     = "projects/${var.project}/subscriptions/${var.subscription_name}"
    outputTableSpec       = "${var.project}:${var.dataset_name}.${var.table_name}"
    outputDeadletterTable = "${var.project}:${var.errors_dataset_name}.${var.errors_table_name}"
  }
}

module "pubsub-to-bigquery" {
  source = "../.."

  project  = var.project
  location = var.location
  region   = var.region
  labels   = var.labels

  create_service_account      = var.create_service_account
  service_account_name        = var.service_account_name
  service_account_description = var.service_account_description
  create_roles                = var.create_roles

  create_bucket = var.create_bucket
  bucket_name   = var.bucket_name

  create_topic = var.create_topic
  topic_name   = var.topic_name
  topic_schema = var.topic_schema == null ? null : {
    type       = var.topic_schema.type
    encoding   = var.topic_schema.encoding
    definition = var.topic_schema.definition
    gcs_path   = null
  }
  create_subscription = var.create_subscription
  subscription_name   = var.subscription_name

  create_dataset      = var.create_dataset
  dataset_name        = var.dataset_name
  dataset_description = var.dataset_description
  create_table        = var.create_table
  table_name          = var.table_name
  table_description   = var.table_description
  table_schema        = var.table_schema

  use_errors_dataset         = true
  create_errors_dataset      = var.create_errors_dataset
  errors_dataset_name        = var.errors_dataset_name
  errors_dataset_description = var.errors_dataset_description
  // Table in the errors dataset is created automatically by the Dataflow job.
  create_errors_table = false
  errors_table_name   = var.errors_table_name

  machine_type = var.machine_type
  max_workers  = var.max_workers
  job_name     = var.job_name
  jobs = toset([for job in var.jobs :
    {
      version    = job.version,
      path       = job.path
      flex       = false
      parameters = merge(local.job_parameters, job.parameters)
    }
  ])
}
