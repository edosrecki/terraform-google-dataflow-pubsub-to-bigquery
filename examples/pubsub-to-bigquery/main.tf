locals {
  prefix = var.prefix == "" ? "" : "${var.prefix}-"
  suffix = var.suffix == "" ? "" : "-${var.suffix}"
}

module "pubsub-to-bigquery" {
  source = "../../modules/pubsub-to-bigquery"

  project  = var.project
  location = "EU"
  region   = "europe-west3"
  labels = {
    environment = "dev"
    source      = "terraform"
  }

  service_account_name = "${local.prefix}service-account${local.suffix}"
  bucket_name          = "${local.prefix}bucket${local.suffix}"
  topic_name           = "${local.prefix}topic${local.suffix}"
  subscription_name    = "${local.prefix}subscription${local.suffix}"
  dataset_name         = replace("${local.prefix}dataset${local.suffix}", "-", "_")
  table_name           = "output"
  errors_dataset_name  = replace("${local.prefix}errors-dataset${local.suffix}", "-", "_")
  errors_table_name    = "errors"
  job_name             = "${local.prefix}job${local.suffix}"

  jobs = toset([
    {
      version    = "1",
      path       = "gs://dataflow-templates/latest/PubSub_Subscription_to_BigQuery"
      parameters = {}
    }
  ])

  topic_schema = {
    type     = "AVRO"
    encoding = "JSON"
    definition = jsonencode({
      name = "Message"
      type = "record"
      fields = [
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
  }

  table_schema = jsonencode([
    {
      name = "key"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "value"
      type = "FLOAT64"
      mode = "REQUIRED"
    }
  ])
}
