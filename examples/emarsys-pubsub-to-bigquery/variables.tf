variable "project" {
  type        = string
  description = "Project ID."
}

variable "prefix" {
  type        = string
  description = "Resource name prefix."
  default     = ""
}

variable "suffix" {
  type        = string
  description = "Resource name prefix."
  default     = ""
}

variable "service_account_name" {
  type        = string
  description = "Service account name for Dataflow job."
}

variable "job_path" {
  type        = string
  description = "Emarsys Dataflow pipeline template path."
}
