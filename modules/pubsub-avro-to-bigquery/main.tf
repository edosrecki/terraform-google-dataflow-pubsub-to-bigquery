locals {
  job_parameters = {
    schemaPath        = "gs://${var.bucket_name}/${var.topic_schema.gcs_path}"
    inputSubscription = "projects/${var.project}/subscriptions/${var.subscription_name}"
    outputTopic       = "projects/${var.project}/topics/${var.errors_topic_name}"
    outputTableSpec   = "${var.project}:${var.dataset_name}.${var.table_name}"
  }
}

module "pubsub-avro-to-bigquery" {
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
    type       = "AVRO"
    encoding   = "BINARY"
    definition = var.topic_schema.definition
    gcs_path   = var.topic_schema.gcs_path
  }
  create_subscription = var.create_subscription
  subscription_name   = var.subscription_name

  create_dataset      = var.create_dataset
  dataset_name        = var.dataset_name
  dataset_description = var.dataset_description
  // Table is created automatically by the Dataflow job
  create_table = false
  table_name   = var.table_name

  use_errors_topic           = true
  create_errors_topic        = var.create_errors_topic
  errors_topic_name          = var.errors_topic_name
  create_errors_subscription = var.create_errors_subscription
  errors_subscription_name   = var.errors_subscription_name

  machine_type = var.machine_type
  max_workers  = var.max_workers
  job_name     = var.job_name
  jobs = toset([for job in var.jobs :
    {
      version    = job.version,
      path       = job.path
      flex       = true
      parameters = merge(local.job_parameters, job.parameters)
    }
  ])
}
