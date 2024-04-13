module "hcp_terraform_project_group_access" { 
  source                = "./project_group_access"
  organization_name     = "TFC-Unification-Test-Org-1"
  group_name            = "test-provider-group"
  project_name          = "test-provider-project"
  api_token_group_name  = "joey-test"
  role                  = "maintain"
}
