provider "tfe" {
  version  = "~> 0.53.0"
}

provider "hcp" { }

# create a test group
resource "hcp_group" "provider_test_group" {
  display_name = "provider_test_group"
  description  = "group created by hcp provider"
}

# create a test project
resource "hcp_project" "provider_test_project" {
  name        = "provider_test_project"
  description = "project created by hcp provider"
}

# groups don't have a "Manage all projects" permission (this is only at the User role), so we must 
# create a role binding to give the group Contributor role or higher to either org level (NOT AS SAFE)
resource hcp_organization_iam_binding "group_org_contributor" {
  principal_id = hcp_group.provider_test_group.resource_id
  role = "roles/contributor"
}

# groups don't have a "Manage all projects" permission (this is only at the User role), so we must 
# create a role binding to give the group Contributor role for the project being created (MORE SAFE, BUT MORE CUMBERSOME)
resource hcp_project_iam_binding "group_project_contributor" {
  principal_id = hcp_group.provider_test_group.resource_id
  project_id = hcp_project.provider_test_project.resource_id
  role = "roles/contributor"
}

# this works without any special permissions because all groups are visible to all users and groups
data "tfe_team" "provider_test_tfe_team" {
  name         = hcp_group.provider_test_group.display_name
  organization = "TFC-Unification-Test-Org-1"
}

# With project permissions granted, now the Team API token can access the Terraform Project ID
data "tfe_project" "provider_test_tfe_project" {
  name = hcp_project.provider_test_project.name
  organization = "TFC-Unification-Test-Org-1"
}

# finally we can assign the Terraform Project Read role for the group to the developer group
resource "tfe_team_project_access" "admin" {
  access       = "read"
  team_id      = data.tfe_team.provider_test_tfe_team.id
  project_id   = data.tfe_project.provider_test_tfe_project.id
}
