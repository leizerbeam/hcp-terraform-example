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
# create a policy that maps the Contributor role to the Group.
data "hcp_iam_policy" "group_contributor" {
  bindings = [
    {
      role = "roles/contributor"
      principals = ["joey-test"] # Name of Team w/ the originating Terraform API Token
    },
  ]
}

# next we must bind the Contributor role to the NEWLY created project so that we can assign another developer group with Terraform read access
resource "hcp_project_iam_policy" "project_policy" {
  project_id  = hcp_project.provider_test_project.resource_id
  policy_data = data.hcp_iam_policy.group_contributor.policy_data
}

# this works without any special permissions because all groups are visible to all users and groups
data "tfe_team" "provider_test_tfe_team" {
  name         = hcp_group.provider_test_group.display_name
  organization = "TFC-Unification-Test-Org-1"
}

# this does not work until we assign my Team API token Project Contributor or higher permission to Group to data source the new tfe_project.id 
data "tfe_project" "provider_test_tfe_project" {
  name = hcp_project.provider_test_project.name
  organization = "TFC-Unification-Test-Org-1"
}

# finally =( - we can assign the Terraform Project Read role for the group to the developer group
resource "tfe_team_project_access" "admin" {
  access       = "read"
  team_id      = data.tfe_team.provider_test_tfe_team.id
  project_id   = data.tfe_project.provider_test_tfe_project.id
}
