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
resource hcp_terraform_group_project_access "test_group_project_maintainer" {
  access       = "terraform_maintain"
  group_id     = hcp_group.id
  project_id   = hcp_project.id
  
}

resource tfe_workspace "provider_test_workspace" {
  name = "provider_test_workspace"
  project_id     = hcp_project.id
}
