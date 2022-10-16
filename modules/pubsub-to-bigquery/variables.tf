variable "project" {
  type        = string
  description = "Project ID."
}

variable "location" {
  type        = string
  description = "Location for Storage bucket, and BigQuery dataset."

  validation {
    condition     = contains(["EU", "US"], var.location)
    error_message = "Location must be one of: 'EU', 'US'"
  }
}

variable "region" {
  type        = string
  description = "Region for Dataflow job."
}

variable "labels" {
  type        = map(any)
  description = "Labels for all resources."
  default     = {}
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Service Account for Dataflow Job
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
variable "create_service_account" {
  type        = bool
  description = "Create service account for Dataflow job?"
  default     = true
}

variable "service_account_name" {
  type        = string
  description = "Service account name for Dataflow job."
}

variable "service_account_description" {
  type        = string
  description = "Service account description for Dataflow job."
  default     = ""
}

variable "create_roles" {
  type        = bool
  description = "Create service account roles for Dataflow job?"
  default     = true
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Storage for Dataflow files
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
variable "create_bucket" {
  type        = bool
  description = "Create Storage bucket for Dataflow files?"
  default     = true
}

variable "bucket_name" {
  type        = string
  description = "Storage bucket name for Dataflow files."
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Pub/Sub input
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
variable "create_topic" {
  type        = bool
  description = "Create Pub/Sub topic for Dataflow input?"
  default     = true
}

variable "topic_name" {
  type        = string
  description = "Pub/Sub topic name for Dataflow input."
}

variable "topic_schema" {
  type = object({
    type       = string
    definition = string
    encoding   = string
  })

  description = "Pub/Sub topic message schema."
  default     = null
}

variable "create_subscription" {
  type        = bool
  description = "Create Pub/Sub subscription for Dataflow input?"
  default     = true
}

variable "subscription_name" {
  type        = string
  description = "Pub/Sub subscription name for Dataflow input."
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// BigQuery success output
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
variable "create_dataset" {
  type        = bool
  description = "Create BigQuery dataset for Dataflow output?"
  default     = true
}

variable "dataset_name" {
  type        = string
  description = "BigQuery dataset name for Dataflow output."
}

variable "dataset_description" {
  type        = string
  description = "BigQuery dataset description for Dataflow output."
  default     = ""
}

variable "create_table" {
  type        = bool
  description = "Create BigQuery table for Dataflow output?"
  default     = true
}

variable "table_name" {
  type        = string
  description = "BigQuery table name for Dataflow output."
}

variable "table_description" {
  type        = string
  description = "BigQuery table description for Dataflow output."
  default     = ""
}

variable "table_schema" {
  type        = string
  description = "BigQuery table JSON schema for Dataflow output."
  default     = null
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// BigQuery failure output
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
variable "create_errors_dataset" {
  type        = bool
  description = "Create BigQuery dataset for Dataflow errors?"
  default     = true
}

variable "errors_dataset_name" {
  type        = string
  description = "BigQuery dataset name for Dataflow errors."
}

variable "errors_dataset_description" {
  type        = string
  description = "BigQuery dataset description for Dataflow errors."
  default     = ""
}

variable "errors_table_name" {
  type        = string
  description = "BigQuery table name for Dataflow errors."
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Dataflow Job(s)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
variable "machine_type" {
  type        = string
  description = "Dataflow worker machine type for the job."
  default     = null
}

variable "max_workers" {
  type        = string
  description = "Maximum number of Dataflow workers for the job."
  default     = null
}

variable "job_name" {
  type        = string
  description = "Dataflow job name."
  default     = "job"
}

variable "jobs" {
  type = set(object({
    version    = string
    path       = string
    parameters = map(string)
  }))

  description = "Dataflow job(s)."
  default     = []
}
