output "project" {
  value       = module.pubsub-avro-to-bigquery.project
  description = "Project ID."
}

output "location" {
  value       = module.pubsub-avro-to-bigquery.location
  description = "Location for Storage bucket, and BigQuery dataset."
}

output "region" {
  value       = module.pubsub-avro-to-bigquery.region
  description = "Region for Dataflow job."
}

output "service_account_email" {
  value       = module.pubsub-avro-to-bigquery.service_account_email
  description = "Service account for Dataflow job."
}

output "bucket_location" {
  value       = module.pubsub-avro-to-bigquery.bucket_location
  description = "Storage bucket location for Dataflow files."
}

output "subscription_name" {
  value       = module.pubsub-avro-to-bigquery.subscription_name
  description = "Pub/Sub subscription name for Dataflow input."
}

output "dataset_name" {
  value       = module.pubsub-avro-to-bigquery.dataset_name
  description = "BigQuery dataset name for Dataflow output."
}

output "table_name" {
  value       = var.table_name
  description = "BigQuery table name for Dataflow output."
}

output "errors_topic_name" {
  value       = module.pubsub-avro-to-bigquery.errors_topic_name
  description = "Pub/Sub topic name for Dataflow errors."
}

output "job_name" {
  value       = module.pubsub-avro-to-bigquery.job_name
  description = "Dataflow job name."
}

output "job_versions" {
  value       = module.pubsub-avro-to-bigquery.job_versions
  description = "Running Dataflow job versions."
}

output "job_parameters" {
  value       = local.job_parameters
  description = "Dataflow job parameters."
}
