locals {
  prefix = var.prefix == "" ? "" : "${var.prefix}-"
  suffix = var.suffix == "" ? "" : "-${var.suffix}"
}

module "pubsub-avro-to-bigquery" {
  source = "../../modules/pubsub-avro-to-bigquery"

  project  = var.project
  location = "EU"
  region   = "europe-west3"
  labels = {
    environment = "dev"
    source      = "terraform"
  }

  service_account_name     = "${local.prefix}service-account${local.suffix}"
  bucket_name              = "${local.prefix}bucket${local.suffix}"
  topic_name               = "${local.prefix}topic${local.suffix}"
  subscription_name        = "${local.prefix}subscription${local.suffix}"
  dataset_name             = replace("${local.prefix}dataset${local.suffix}", "-", "_")
  table_name               = "output"
  errors_topic_name        = "${local.prefix}errors-topic${local.suffix}"
  errors_subscription_name = "${local.prefix}errors-subscription${local.suffix}"
  job_name                 = "${local.prefix}job${local.suffix}"

  jobs = toset([
    {
      version    = "1",
      path       = "gs://dataflow-templates/latest/flex/PubSub_Avro_to_BigQuery"
      parameters = {}
    }
  ])

  topic_schema = {
    gcs_path = "schemas/message-schema.avsc"
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
        },
        {
          name = "event_time"
          type = { type = "int", logicalType = "date" }
        }
      ]
    })
  }
}
