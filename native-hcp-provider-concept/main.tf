# Pre-requisites: configure sensitive environmental variablee
# HCP_CLIENT_ID # Service Principal should be created in the HCP Org you are trying to manage and assigned Org Admin Role to create Projects and Groups in that HCP Org
# HCP_CLIENT_SECRET
provider "hcp" { }

# create a test group
resource hcp_group "provider_test_group" {
  display_name   = "provider_test_group"
  description    = "group created by hcp provider"
}

# create a test project
resource hcp_project "provider_test_project" {
  name          = "provider_test_project"
  description   = "project created by hcp provider"
}

# Assign the Terraform Project Maintainer role to the developer group
resource "hcp_project_iam_binding" "provider_test_project_maintain" {
  project_id   = hcp_project.example.resource_id
  principal_id = hcp_group.provider_test_group.resource_id
  role         = "roles/terraform_maintain"
}

resource hcp_terraform_workspace "provider_test_europe_workspace" {
  name         = "provider_test_workspace"
  project_id   = hcp_project.provider_test_project.resource_id
  geo          = "us"
}

resource hcp_terraform_workspace "provider_test_us_workspace" {
  name         = "provider_test_workspace"
  project_id   = hcp_project.provider_test_project.resource_id
  geo          = "eu"
}

resource "hcp_vault_secrets_secret" "example" {
  app_name     = "example-app-name"
  secret_name  = "example_secret"
  secret_value = var.secret
}

resource "hcp_terraform_variable" "test" {
  key          = "my_key_name"
  value        = hcp_vault_secrets_secret.secret_value
  category     = "terraform"
  workspace_id = hcp_terraform_workspace.provider_test_us_workspace.id
  description  = "a useful description"
}
