locals {
  job_parameters = {
    inputSubscription  = "projects/${var.project}/subscriptions/${var.subscription_name}"
    outputTableSpec    = "${var.project}:${var.dataset_name}.${var.table_name}"
    outputTableSchema  = var.table_schema
    writeCommonTable   = true
    writeCustomerTable = true
    fieldTransforms    = jsonencode([])
  }
}

module "emarsys-pubsub-to-bigquery" {
  source = "../.."

  project  = var.project
  location = var.location
  region   = var.region
  labels   = var.labels

  // Service account needs to be given access to Container Registry private image
  // for the Dataflow job. Thus it has to be managed outside this module.
  create_service_account = false
  service_account_name   = var.service_account_name
  create_roles           = var.create_roles

  create_bucket = var.create_bucket
  bucket_name   = var.bucket_name

  create_topic = var.create_topic
  topic_name   = var.topic_name
  topic_schema = var.topic_schema == null ? null : {
    definition = var.topic_schema
    type       = "AVRO"
    encoding   = "JSON"
    gcs_path   = null
  }
  create_subscription = var.create_subscription
  subscription_name   = var.subscription_name

  create_dataset      = var.create_dataset
  dataset_name        = var.dataset_name
  dataset_description = var.dataset_description
  // Table(s) in the dataset are created automatically by the Dataflow job.
  create_table = false

  // Failures are written to the errors dataset in a table named after the Dataflow job.
  use_errors_dataset         = true
  create_errors_dataset      = var.create_errors_dataset
  errors_dataset_name        = "dataflow_errors"
  errors_dataset_description = var.errors_dataset_description
  // Table in the errors dataset is created automatically by the Dataflow job.
  create_errors_table = false

  // Failures that cannot be written to the errors dataset are written into the
  // errors bucket in a folder named after the Dataflow job.
  use_errors_bucket    = true
  create_errors_bucket = var.create_errors_bucket
  errors_bucket_name   = "${var.project}-dataflow-errors"

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
