output "project" {
  value       = module.emarsys-pubsub-to-bigquery.project
  description = "Project ID."
}

output "location" {
  value       = module.emarsys-pubsub-to-bigquery.location
  description = "Location for Storage bucket, and BigQuery dataset."
}

output "region" {
  value       = module.emarsys-pubsub-to-bigquery.region
  description = "Region for Dataflow job."
}

output "service_account_email" {
  value       = module.emarsys-pubsub-to-bigquery.service_account_email
  description = "Service account for Dataflow job."
}

output "bucket_location" {
  value       = module.emarsys-pubsub-to-bigquery.bucket_location
  description = "Storage bucket location for Dataflow files."
}

output "subscription_name" {
  value       = module.emarsys-pubsub-to-bigquery.subscription_name
  description = "Pub/Sub subscription name for Dataflow input."
}

output "dataset_name" {
  value       = module.emarsys-pubsub-to-bigquery.dataset_name
  description = "BigQuery dataset name for Dataflow output."
}

output "table_name" {
  value       = module.emarsys-pubsub-to-bigquery.table_name
  description = "BigQuery table name for Dataflow output."
}

output "errors_bucket_location" {
  value       = module.emarsys-pubsub-to-bigquery.errors_bucket_location
  description = "Storage bucket location for Dataflow errors."
}

output "errors_dataset_name" {
  value       = module.emarsys-pubsub-to-bigquery.errors_dataset_name
  description = "BigQuery dataset name for Dataflow errors"
}

output "job_name" {
  value       = module.emarsys-pubsub-to-bigquery.job_name
  description = "Dataflow job name."
}

output "job_versions" {
  value       = module.emarsys-pubsub-to-bigquery.job_versions
  description = "Running Dataflow job versions."
}

output "job_parameters" {
  value       = module.emarsys-pubsub-to-bigquery.job_parameters
  description = "Dataflow job parameters."
}
