# Emarsys Pub/Sub to BigQuery Dataflow Pipeline

## Requirements

* Deployer of this module needs to get access to read metadata JSON file for
  the Dataflow pipeline, which is stored in a Storage bucket.

* Create a service account and ask that it gets the IAM role to access Docker
  image for the Dataflow pipeline, which is stored in the Container Registry.
  This cannot be done automatically inside this module. However, other roles
  required for the pipeline are managed by the module.

* Pipeline uses fixed Storage bucket, and BigQuery dataset for failed records
  storage. Therefore you probably want to manage those outside this module,
  and opt out from their creation by setting `create_errors_bucket` and
  `create_errors_dataset` to `false`.

## Usage

Check `examples/emarsys-pubsub-to-bigquery` for runnable code.

```hcl
module "emarsys-pubsub-to-bigquery" {
  source = "edosrecki/dataflow-pubsub-to-bigquery/google//modules/emarsys-pubsub-to-bigquery"

  project  = "example-project"
  location = "EU"
  region   = "europe-west3"
  labels = {
    environment = "dev"
    source      = "terraform"
  }

  service_account_name = "example-service-account"
  bucket_name          = "example-bucket"
  topic_name           = "example-input-topic"
  subscription_name    = "example-input-subscription"
  dataset_name         = "example_dataset"
  table_name           = "output"
  job_name             = "example-job"
  jobs = toset([
    {
      version    = "1",
      path       = "gs://[PATH-TO-PUBSUB-TO-BIGQUERY-FLEX-TEMPLATE]"
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
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bucket\_name | Storage bucket name for Dataflow files. | `string` | n/a | yes |
| create\_bucket | Create Storage bucket for Dataflow files? | `bool` | `true` | no |
| create\_dataset | Create BigQuery dataset for Dataflow output? | `bool` | `true` | no |
| create\_errors\_bucket | Create Storage bucket for Dataflow errors? | `bool` | `true` | no |
| create\_errors\_dataset | Create BigQuery dataset for Dataflow errors? | `bool` | `true` | no |
| create\_roles | Create service account roles for Dataflow job? | `bool` | `true` | no |
| create\_subscription | Create Pub/Sub subscription for Dataflow input? | `bool` | `true` | no |
| create\_topic | Create Pub/Sub topic for Dataflow input? | `bool` | `true` | no |
| dataset\_description | BigQuery dataset description for Dataflow output. | `string` | `""` | no |
| dataset\_name | BigQuery dataset name for Dataflow output. | `string` | n/a | yes |
| errors\_dataset\_description | BigQuery dataset description for Dataflow errors. | `string` | `""` | no |
| job\_name | Dataflow job name. | `string` | n/a | yes |
| jobs | Dataflow job(s). | <pre>set(object({<br>    version    = string<br>    path       = string<br>    parameters = map(string)<br>  }))</pre> | n/a | yes |
| labels | Labels for all resources. | `map(any)` | `{}` | no |
| location | Location for Storage bucket, and BigQuery dataset. | `string` | `"EU"` | no |
| machine\_type | Dataflow worker machine type for the job. | `string` | `null` | no |
| max\_workers | Maximum number of Dataflow workers for the job. | `string` | `null` | no |
| project | Project ID. | `string` | n/a | yes |
| region | Region for Dataflow job. | `string` | `"europe-west3"` | no |
| service\_account\_name | Service account name for Dataflow job. | `string` | n/a | yes |
| subscription\_name | Pub/Sub subscription name for Dataflow input. | `string` | n/a | yes |
| table\_name | BigQuery table name for Dataflow output. | `string` | n/a | yes |
| table\_schema | BigQuery table JSON schema for Dataflow output. | `string` | n/a | yes |
| topic\_name | Pub/Sub topic name for Dataflow input. | `string` | n/a | yes |
| topic\_schema | Pub/Sub topic message schema definition in AVRO format. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket\_location | Storage bucket location for Dataflow files. |
| dataset\_name | BigQuery dataset name for Dataflow output. |
| errors\_bucket\_location | Storage bucket location for Dataflow errors. |
| errors\_dataset\_name | BigQuery dataset name for Dataflow errors |
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
