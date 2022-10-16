# Pub/Sub to BigQuery Dataflow Pipeline Example

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| prefix | Resource name prefix. | `string` | `""` | no |
| project | Project ID. | `string` | n/a | yes |
| suffix | Resource name prefix. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket\_location | Storage bucket location for Dataflow files. |
| dataset\_name | BigQuery dataset name for Dataflow output. |
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
