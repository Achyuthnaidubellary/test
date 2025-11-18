terraform {
  required_version = ">= 1.0"
}

# REAL SCENARIO: Terraform best practice uses lowercase snake_case variables
# But GitHub environment variables are typically UPPERCASE
# Testing if they can map to each other

variable "environment_name" {
  description = "Environment name (lowercase - Terraform best practice)"
  type        = string
  default     = "default-env"
}

variable "project_id" {
  description = "Project ID (lowercase - Terraform best practice)"
  type        = string
  default     = "default-project"
}

variable "region" {
  description = "AWS/Cloud region (lowercase)"
  type        = string
  default     = "default-region"
}

variable "cluster_name" {
  description = "Cluster name (lowercase)"
  type        = string
  default     = "default-cluster"
}

variable "name" {
  description = "Name variable (lowercase) - testing against TF_VAR_NAME from GitHub"
  type        = string
  default     = "default-name"
}

# For comparison: UPPERCASE variables (not best practice but testing)
variable "ENVIRONMENT_NAME" {
  description = "UPPERCASE version for testing"
  type        = string
  default     = "DEFAULT-UPPER"
}

variable "PROJECT_ID" {
  description = "UPPERCASE version for testing"
  type        = string
  default     = "DEFAULT-UPPER-PROJECT"
}

variable "NAME" {
  description = "NAME in UPPERCASE for testing"
  type        = string
  default     = "DEFAULT-NAME-UPPER"
}

# Test JSON variable
variable "config_map" {
  description = "JSON configuration map (lowercase)"
  type        = string
  default     = "{\"default\": true}"
}

variable "CONFIG_MAP" {
  description = "JSON configuration map (UPPERCASE)"
  type        = string
  default     = "{\"default\": true, \"upper\": true}"
}

# Output to see what values were actually set
output "test_results" {
  description = "Shows which variables received values from GitHub env vars"
  value = {
    environment_name_lowercase  = var.environment_name
    project_id_lowercase        = var.project_id
    region_lowercase            = var.region
    cluster_name_lowercase      = var.cluster_name
    name_lowercase              = var.name
    ENVIRONMENT_NAME_UPPERCASE  = var.ENVIRONMENT_NAME
    PROJECT_ID_UPPERCASE        = var.PROJECT_ID
    NAME_UPPERCASE              = var.NAME
    config_map_lowercase        = var.config_map
    CONFIG_MAP_UPPERCASE        = var.CONFIG_MAP
  }
}

output "case_mapping_test" {
  description = "Test results showing if GitHub UPPERCASE mapped to Terraform lowercase"
  value = {
    test_1 = var.environment_name == "default-env" ? "❌ FAILED: TF_VAR_ENVIRONMENT_NAME did NOT map to lowercase" : "✅ PASSED: Received value from GitHub"
    test_2 = var.ENVIRONMENT_NAME == "DEFAULT-UPPER" ? "❌ FAILED: No UPPERCASE GitHub var set this" : "✅ PASSED: TF_VAR_ENVIRONMENT_NAME mapped to UPPERCASE var"
    test_3 = var.name == "default-name" ? "❌ TF_VAR_NAME did NOT map to lowercase 'name'" : "✅ TF_VAR_NAME='${var.name}' set lowercase 'name'"
    test_4 = var.NAME == "DEFAULT-NAME-UPPER" ? "❌ TF_VAR_NAME did NOT map to UPPERCASE 'NAME'" : "✅ TF_VAR_NAME='${var.NAME}' set UPPERCASE 'NAME'"
    conclusion = "Case-sensitive mapping required: TF_VAR_name for 'name', TF_VAR_NAME for 'NAME'"
  }
}

# Local file to demonstrate successful execution
resource "local_file" "test_output" {
  filename = "${path.module}/terraform-output.txt"
  content  = <<-EOT
    Terraform Case Sensitivity Test Results
    ========================================
    SCENARIO: GitHub UPPERCASE env vars → Terraform lowercase variables
    
    Lowercase Terraform Variables (best practice):
    ----------------------------------------------
    environment_name: ${var.environment_name}
    project_id: ${var.project_id}
    region: ${var.region}
    cluster_name: ${var.cluster_name}
    name: ${var.name}
    
    UPPERCASE Terraform Variables (for comparison):
    -----------------------------------------------
    ENVIRONMENT_NAME: ${var.ENVIRONMENT_NAME}
    PROJECT_ID: ${var.PROJECT_ID}
    NAME: ${var.NAME}
    
    JSON Variables Test:
    --------------------
    config_map (lowercase): ${var.config_map}
    CONFIG_MAP (UPPERCASE): ${var.CONFIG_MAP}
    
    FINDINGS:
    --------
    ❌ TF_VAR_ENVIRONMENT_NAME does NOT map to 'environment_name'
    ✅ TF_VAR_ENVIRONMENT_NAME DOES map to 'ENVIRONMENT_NAME'
    
    Testing GitHub Environment Variable (TF_VAR_NAME = "prani"):
    ${var.name == "prani" ? "✅ TF_VAR_NAME mapped to lowercase 'name'" : "❌ TF_VAR_NAME did NOT map to lowercase 'name'"}
    ${var.NAME == "prani" ? "✅ TF_VAR_NAME mapped to UPPERCASE 'NAME'" : "❌ TF_VAR_NAME did NOT map to UPPERCASE 'NAME'"}
    
    SOLUTION: Use exact case in GitHub env vars or transform in workflow
    
    Test completed at: ${timestamp()}
  EOT
}
