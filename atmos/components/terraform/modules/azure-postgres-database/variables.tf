# General Variables
variable "enabled" {
  description = "Set to false to prevent the module from creating any resources"
  type        = bool
  default     = true
}

# Database Variables
variable "server_id" {
  description = "The ID of the PostgreSQL Flexible Server on which to create the database"
  type        = string
}

variable "database_name" {
  description = "Custom name for the database. If not provided, will use the label module generated ID"
  type        = string
  default     = null
}

variable "collation" {
  description = "Specifies the collation of the database"
  type        = string
  default     = "en_US.utf8"
  validation {
    condition     = can(regex("^[a-zA-Z0-9_.-]+$", var.collation))
    error_message = "Collation must be a valid PostgreSQL collation name"
  }
}

variable "charset" {
  description = "Specifies the charset of the database"
  type        = string
  default     = "UTF8"
  validation {
    condition     = contains(["UTF8", "SQL_ASCII", "LATIN1", "LATIN2", "LATIN3", "LATIN4", "LATIN5", "LATIN6", "LATIN7", "LATIN8", "LATIN9", "LATIN10"], var.charset)
    error_message = "Charset must be a valid PostgreSQL character set"
  }
}

# Label Module Variables
variable "namespace" {
  description = "ID element. Usually an abbreviation of your organization name"
  type        = string
  default     = null
}

variable "tenant" {
  description = "ID element. Usually used to indicate the tenant"
  type        = string
  default     = null
}

variable "environment" {
  description = "ID element. Usually used for region (e.g. 'eus', 'weu')"
  type        = string
  default     = null
}

variable "stage" {
  description = "ID element. Usually used to indicate role (e.g. 'prod', 'dev')"
  type        = string
  default     = null
}

variable "name" {
  description = "ID element. Usually the component or solution name"
  type        = string
  default     = null
}

variable "attributes" {
  description = "ID element. Additional attributes to add to ID"
  type        = list(string)
  default     = []
}

variable "delimiter" {
  description = "Delimiter to be used between ID elements"
  type        = string
  default     = "-"
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}

variable "regex_replace_chars" {
  description = "Regex string to remove characters from ID elements"
  type        = string
  default     = null
}

variable "label_order" {
  description = "The order in which the labels appear in the id"
  type        = list(string)
  default     = null
}

variable "label_key_case" {
  description = "Controls the letter case of tag keys"
  type        = string
  default     = null
}

variable "label_value_case" {
  description = "Controls the letter case of tag values"
  type        = string
  default     = null
}

variable "id_length_limit" {
  description = "Limit id to this many characters"
  type        = number
  default     = null
}
