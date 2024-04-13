# Pre-requisites: configure sensitive environmental variables
# TFE_TOKEN <- Team API Token
provider "tfe" {
  version  = "~> 0.53.0"
}

# Pre-requisites: configure sensitive environmental variables
# HCP_CLIENT_ID <- Service Principal Role Admin
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

# hardcoded name of team api token to enable principal_id role binding
data hcp_group "joey-test-team" {
  resource_name = "joey-test" 
}

# HCP doesn't have a "Manage all projects" FGR (this is only at the Admin User role currently), so we must 
# create a role binding to give the Group an Admin at the org level (NOT LEAST PRIVILEGE)
#resource hcp_organization_iam_binding "group_org_admin" {
#  principal_id   = "joey-test" # hardcoded name of team api token
#  role           = "roles/admin" # only admins can manage project role assignment
#}

# Alternatively, we give Project Admin access to to Team API Token (MORE SAFE, BUT NEEDS TO BE DONE FOR EACH PROJECT BEING CREATED)
# Note: We will need Terraform Project Admin to become more least privilege; and to apply Global Exclusion Policies on top of this.
resource hcp_project_iam_binding "group_project_admin" {
  principal_id   = data.hcp_group.joey-test-team.resource_id
  project_id     = hcp_project.provider_test_project.resource_id
  role           = "roles/admin" # only admins can manage project role assignment
}

# this works without any special permissions because all groups are visible to all users and groups
data tfe_team "provider_test_tfe_team" {
  name           = hcp_group.provider_test_group.display_name
  organization   = "TFC-Unification-Test-Org-1" # could be possibly substituted with data.hcp_organization.name
}

# The Team API token has no access to the synced Terraform project without first applying the above hcp_project_iam_binding
# This is an HCP Terraform application level explicit dependency that 'terraform' could not infer from the configuration without erroring out
data tfe_project "provider_test_tfe_project" {
  name = hcp_project.provider_test_project.name
  organization   = "TFC-Unification-Test-Org-1" # could be possibly substituted with data.hcp_organization.name
  depends_on     = [hcp_project_iam_binding.group_project_admin]
}

# Assign the Terraform Project Maintainer role to the developer group
# This is an HCP Terraform application level explicit dependency that 'terraform' could not infer from the configuration without erroring out
resource tfe_team_project_access "test_group_project_maintainer" {
  access       = "maintain"
  team_id      = data.tfe_team.provider_test_tfe_team.id
  project_id   = data.tfe_project.provider_test_tfe_project.id
  depends_on   = [hcp_project_iam_binding.group_project_admin]
}

resource tfe_workspace "provider_test_workspace" {
  name = "provider_test_workspace"
  organization   = "TFC-Unification-Test-Org-1" # could be possibly substituted with data.hcp_organization.name
  project_id     = data.tfe_project.provider_test_tfe_project.id
}
