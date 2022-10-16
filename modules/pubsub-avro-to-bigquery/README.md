# Pub/Sub Avro to BigQuery Dataflow Pipeline

Deploy a Pub/Sub Avro to BigQuery Dataflow pipeline template [provided by Google](https://cloud.google.com/dataflow/docs/guides/templates/provided-streaming#pubsub-avro-to-bigquery).

By default, this module also deploys additional resources needed for the pipeline,
e.g. service account and necessary roles, Pub/Sub topic, topic schema, and subscription,
Storage bucket for Dataflow job temporary files, BigQuery dataset and table for output
records, and Pub/Sub topic and subscription for failed records. If you already manage
some of these resources you can opt out from deploying them by using `create_*` inputs.

## Usage

```hcl
module "pubsub-avro-to-bigquery" {
  source = "edosrecki/dataflow-pubsub-to-bigquery/google//modules/pubsub-avro-to-bigquery"

  project  = "example-project"
  location = "EU"
  region   = "europe-west3"
  labels = {
    environment = "dev"
    source      = "terraform"
  }

  service_account_name     = "example-service-account"
  bucket_name              = "example-bucket"
  topic_name               = "example-input-topic"
  subscription_name        = "example-input-subscription"
  dataset_name             = "example_dataset"
  table_name               = "output"
  errors_topic_name        = "example-errors-topic"
  errors_subscription_name = "example-errors-subscription"
  job_name                 = "example-job"

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
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bucket\_name | Storage bucket name for Dataflow files. | `string` | n/a | yes |
| create\_bucket | Create Storage bucket for Dataflow files? | `bool` | `true` | no |
| create\_dataset | Create BigQuery dataset for Dataflow output? | `bool` | `true` | no |
| create\_errors\_subscription | Create Pub/Sub subscription for Dataflow errors? | `bool` | `true` | no |
| create\_errors\_topic | Create Pub/Sub topic for Dataflow errors? | `bool` | `true` | no |
| create\_roles | Create service account roles for Dataflow job? | `bool` | `true` | no |
| create\_service\_account | Create service account for Dataflow job? | `bool` | `true` | no |
| create\_subscription | Create Pub/Sub subscription for Dataflow input? | `bool` | `true` | no |
| create\_topic | Create Pub/Sub topic for Dataflow input? | `bool` | `true` | no |
| dataset\_description | BigQuery dataset description for Dataflow output. | `string` | `""` | no |
| dataset\_name | BigQuery dataset name for Dataflow output. | `string` | n/a | yes |
| errors\_subscription\_name | Pub/Sub subscription name for Dataflow errors. | `string` | `"errors-subscription"` | no |
| errors\_topic\_name | Pub/Sub topic name for Dataflow errors. | `string` | `"errors-topic"` | no |
| job\_name | Dataflow job name. | `string` | `"job"` | no |
| jobs | Dataflow job(s). | <pre>set(object({<br>    version    = string<br>    path       = string<br>    parameters = map(string)<br>  }))</pre> | `[]` | no |
| labels | Labels for all resources. | `map(any)` | `{}` | no |
| location | Location for Storage bucket, and BigQuery dataset. | `string` | n/a | yes |
| machine\_type | Dataflow worker machine type for the job. | `string` | `null` | no |
| max\_workers | Maximum number of Dataflow workers for the job. | `string` | `null` | no |
| project | Project ID. | `string` | n/a | yes |
| region | Region for Dataflow job. | `string` | n/a | yes |
| service\_account\_description | Service account description for Dataflow job. | `string` | `""` | no |
| service\_account\_name | Service account name for Dataflow job. | `string` | n/a | yes |
| subscription\_name | Pub/Sub subscription name for Dataflow input. | `string` | n/a | yes |
| table\_name | BigQuery table name for Dataflow output. | `string` | n/a | yes |
| topic\_name | Pub/Sub topic name for Dataflow input. | `string` | n/a | yes |
| topic\_schema | Pub/Sub topic message schema definition and path inside Storage bucket. | <pre>object({<br>    definition = string<br>    gcs_path   = string<br>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket\_location | Storage bucket location for Dataflow files. |
| dataset\_name | BigQuery dataset name for Dataflow output. |
| errors\_topic\_name | Pub/Sub topic name for Dataflow errors. |
| job\_name | Dataflow job name. |
| job\_parameters | Dataflow job parameters. |
| job\_versions | Running Dataflow job versions. |
| location | Location for Storage bucket, and BigQuery dataset. |
| project | Project ID. |
| region | Region for Dataflow job. |
| service\_account\_email | Service account for Dataflow job. |
| subscription\_name | Pub/Sub subscription name for Dataflow input. |
| table\_name | BigQuery table name for Dataflow output. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
