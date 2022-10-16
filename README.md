# Terraform Dataflow Pub/Sub to BigQuery Module

Deploy various types of Pub/Sub to BigQuery Dataflow pipeline templates, either ones
[provided by Google](https://cloud.google.com/dataflow/docs/guides/templates/provided-streaming),
or custom ones.

It supports both classic and flex Dataflow templates, and it can deploy multiple jobs in
parallel, so that you can first migrate to a new job version before draining the old
pipeline. For each job you can specify additional parameters which you can use in your pipeline
code.

This module can deploy additional resources needed for the pipeline, e.g. service account
and necessary roles, Pub/Sub topic, topic schema, and subscription, Storage bucket for Dataflow
job temporary files, BigQuery dataset and table for output records, Storage bucekt for failed
reords, BigQuery dataset and table for failed records, and Pub/Sub topic and subscription for
failed records.

Based on the implementation of the pipeline that you want to deploy, you can opt in to deployment
of different resources by using `use_*` inputs. For example, if your pipeline is writing failed
records to a Pub/Sub topic, you can set `use_errors_topic = true`.

Additional resources needed for the pipeline execution are created by default, but you can opt
out of their deployment with `create_*` inputs. For example, if you already manage the service
account for the job outside of this module, you can set `create_service_account = false`.

## Usage

This example deploys a simple pipeline which consumes from a Pub/Sub subscription, writes
successfully processed records to a BigQuery dataset, while failed records are written to a
different BigQuery dataset. It uses a classic Dataflow pipeline made available by Google.

In this example all the necessary resources are managed by the module, so it can be used to
quickly provision the whole environment.

For simpler usage check available submodules in `module/`, and example use cases in `examples/`.

```hcl
module "dataflow-pubsub-to-bigquery" {
  source = "edosrecki/dataflow-pubsub-to-bigquery/google"

  project  = "example-project"
  location = "EU"
  region   = "europe-west3"
  labels = {
    environment = "dev"
  }

  service_account_name = "example-service-account"
  bucket_name          = "example-bucket"
  topic_name           = "example-input-topic"
  subscription_name    = "example-input-subscription"
  dataset_name         = "example_dataset"
  table_name           = "output"
  use_errors_dataset   = true
  errors_dataset_name  = "example_errors_dataset"
  create_errors_table  = false
  errors_table_name    = "errors"
  job_name             = "example-job"

  jobs = toset([
    {
      version    = "1",
      path       = "gs://dataflow-templates/latest/PubSub_Subscription_to_BigQuery"
      flex       = false
      parameters = {
        inputSubscription     = "projects/example-project/subscriptions/example-subscription"
        outputTableSpec       = "example-project:example_dataset.output"
        outputDeadletterTable = "example-project:example_errors_dataset.errors"
      }
    }
  ])

  topic_schema = {
    type     = "AVRO"
    encoding = "JSON"
    gcs_path = null
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
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bucket\_name | Storage bucket name for Dataflow files. | `string` | `"bucket"` | no |
| create\_bucket | Create Storage bucket for Dataflow files? | `bool` | `true` | no |
| create\_dataset | Create BigQuery dataset for Dataflow output? | `bool` | `true` | no |
| create\_errors\_bucket | Create Storage bucket for Dataflow errors? | `bool` | `true` | no |
| create\_errors\_dataset | Create BigQuery dataset for Dataflow errors? | `bool` | `true` | no |
| create\_errors\_subscription | Create Pub/Sub subscription for Dataflow errors? | `bool` | `true` | no |
| create\_errors\_table | Create BigQuery table for Dataflow errors? | `bool` | `true` | no |
| create\_errors\_topic | Create Pub/Sub topic for Dataflow errors? | `bool` | `true` | no |
| create\_roles | Create service account roles for Dataflow job? | `bool` | `true` | no |
| create\_service\_account | Create service account for Dataflow job? | `bool` | `true` | no |
| create\_subscription | Create Pub/Sub subscription for Dataflow input? | `bool` | `true` | no |
| create\_table | Create BigQuery table for Dataflow output? | `bool` | `true` | no |
| create\_topic | Create Pub/Sub topic for Dataflow input? | `bool` | `true` | no |
| dataset\_description | BigQuery dataset description for Dataflow output. | `string` | `""` | no |
| dataset\_name | BigQuery dataset name for Dataflow output. | `string` | `"dataset"` | no |
| errors\_bucket\_name | Storage bucket name for Dataflow errors. | `string` | `"errors-bucket"` | no |
| errors\_dataset\_description | BigQuery dataset description for Dataflow errors. | `string` | `""` | no |
| errors\_dataset\_name | BigQuery dataset name for Dataflow errors. | `string` | `"errors-dataset"` | no |
| errors\_subscription\_name | Pub/Sub subscription name for Dataflow errors. | `string` | `"errors-subscription"` | no |
| errors\_table\_description | BigQuery table description for Dataflow errors. | `string` | `""` | no |
| errors\_table\_name | BigQuery table name for Dataflow errors. | `string` | `"table"` | no |
| errors\_topic\_name | Pub/Sub topic name for Dataflow errors. | `string` | `"errors-topic"` | no |
| job\_name | Dataflow job name. | `string` | `"job"` | no |
| jobs | Dataflow job(s). | <pre>set(object({<br>    version    = string<br>    path       = string<br>    flex       = bool<br>    parameters = map(string)<br>  }))</pre> | `[]` | no |
| labels | Labels for all resources. | `map(any)` | `{}` | no |
| location | Location for Storage bucket, and BigQuery dataset. | `string` | `"EU"` | no |
| machine\_type | Dataflow worker machine type for the job. | `string` | `null` | no |
| max\_workers | Maximum number of Dataflow workers for the job. | `string` | `null` | no |
| project | Project ID. | `string` | n/a | yes |
| region | Region for Dataflow job. | `string` | `"europe-west3"` | no |
| service\_account\_description | Service account description for Dataflow job. | `string` | `""` | no |
| service\_account\_name | Service account name for Dataflow job. | `string` | `"service-account"` | no |
| subscription\_name | Pub/Sub subscription name for Dataflow input. | `string` | `"subscription"` | no |
| table\_description | BigQuery table description for Dataflow output. | `string` | `""` | no |
| table\_name | BigQuery table name for Dataflow output. | `string` | `"table"` | no |
| table\_schema | BigQuery table JSON schema for Dataflow output. | `string` | `null` | no |
| temp\_folder\_name | Storage bucket folder name for Dataflow temporary files. | `string` | `"temp"` | no |
| topic\_name | Pub/Sub topic name for Dataflow input. | `string` | `"topic"` | no |
| topic\_schema | Pub/Sub topic message schema. | <pre>object({<br>    type       = string<br>    definition = string<br>    encoding   = string<br>    gcs_path   = string<br>  })</pre> | `null` | no |
| use\_errors\_bucket | Use Storage bucket for Dataflow errors? | `bool` | `false` | no |
| use\_errors\_dataset | Use BigQuery dataset for Dataflow errors? | `bool` | `false` | no |
| use\_errors\_topic | Use Pub/Sub topic for Dataflow errors? | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket\_location | Storage bucket location for Dataflow files. |
| dataset\_name | BigQuery dataset name for Dataflow output. |
| errors\_bucket\_location | Storage bucket location for Dataflow errors. |
| errors\_dataset\_name | BigQuery dataset name for Dataflow errors |
| errors\_topic\_name | Pub/Sub topic name for Dataflow errors. |
| job\_name | Dataflow job name. |
| job\_versions | Running Dataflow job versions. |
| location | Location for Storage bucket, and BigQuery dataset. |
| project | Project ID. |
| region | Region for Dataflow job. |
| service\_account\_email | Service account for Dataflow job. |
| subscription\_name | Pub/Sub subscription name for Dataflow input. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
