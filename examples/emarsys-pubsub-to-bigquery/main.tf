locals {
  prefix = var.prefix == "" ? "" : "${var.prefix}-"
  suffix = var.suffix == "" ? "" : "-${var.suffix}"
}

module "emarsys-pubsub-to-bigquery" {
  source = "../../modules/emarsys-pubsub-to-bigquery"

  project  = var.project
  location = "EU"
  region   = "europe-west3"
  labels = {
    environment = "test"
    source      = "terraform"
  }

  service_account_name = var.service_account_name
  bucket_name          = "${local.prefix}bucket${local.suffix}"
  topic_name           = "${local.prefix}topic${local.suffix}"
  subscription_name    = "${local.prefix}subscription${local.suffix}"
  dataset_name         = replace("${local.prefix}dataset${local.suffix}", "-", "_")
  table_name           = "output"
  // Errors bucket and dataset are managed outside this module
  create_errors_bucket  = false
  create_errors_dataset = false
  job_name              = "${local.prefix}job${local.suffix}"

  jobs = toset([
    {
      version    = "1",
      path       = var.job_path
      parameters = {}
    }
  ])

  topic_schema = jsonencode({
    name = "Message"
    type = "record"
    fields = [
      {
        name = "customer_id"
        type = "int"
      },
      {
        name = "key"
        type = "string"
      },
      {
        name = "value"
        type = "double"
      }
    ]
  })

  table_schema = jsonencode({
    fields = [
      {
        name = "customer_id"
        type = "INT64"
        mode = "REQUIRED"
      },
      {
        name = "key"
        type = "STRING"
        mode = "REQUIRED"
      },
      {
        name = "value"
        type = "FLOAT64"
        mode = "REQUIRED"
      },
      {
        name = "loaded_at"
        type = "TIMESTAMP"
        mode = "REQUIRED"
      }
    ]
  })
}
