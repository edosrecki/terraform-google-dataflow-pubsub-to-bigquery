output "project" {
  value       = var.project
  description = "Project ID."
}

output "location" {
  value       = var.location
  description = "Location for Storage bucket, and BigQuery dataset."
}

output "region" {
  value       = var.region
  description = "Region for Dataflow job."
}

output "service_account_email" {
  value       = local.service_account_email
  description = "Service account for Dataflow job."
}

output "bucket_location" {
  value       = "gs://${local.bucket_name}"
  description = "Storage bucket location for Dataflow files."
}

output "subscription_name" {
  value       = local.subscription_name
  description = "Pub/Sub subscription name for Dataflow input."
}

output "dataset_name" {
  value       = local.dataset_name
  description = "BigQuery dataset name for Dataflow output."
}

output "errors_bucket_location" {
  value       = var.use_errors_bucket ? "gs://${local.errors_bucket_name}" : null
  description = "Storage bucket location for Dataflow errors."
}

output "errors_dataset_name" {
  value       = var.use_errors_dataset ? local.errors_dataset_name : null
  description = "BigQuery dataset name for Dataflow errors"
}

output "errors_topic_name" {
  value       = var.use_errors_topic ? local.errors_topic_name : null
  description = "Pub/Sub topic name for Dataflow errors."
}

output "job_name" {
  value       = local.job_name
  description = "Dataflow job name."
}

output "job_versions" {
  value       = join(", ", [for job in var.jobs : job.version])
  description = "Running Dataflow job versions."
}
