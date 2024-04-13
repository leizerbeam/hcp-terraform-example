terraform {

  cloud {
    organization = "TFC-Unification-Test-Org-1"
    hostname = "app.eu.terraform.io"

    workspaces {
      name = "test-unified-provider-joey"
    }
  }

  required_providers {
    tfe = {
      source = "hashicorp/tfe"
      version = "0.53.0"
    }

    hcp = {
      source = "hashicorp/hcp"
      version = "0.86.0"
    }
  }
  required_version = "~> 1.2"
}

# Pre-requisites: configure sensitive environmental variables
# TFE_TOKEN <- Team API Token
provider "tfe" {
  version  = "~> 0.53.0"
}

# Pre-requisites: configure sensitive environmental variables
# HCP_CLIENT_ID <- Service Principal Role Admin
# HCP_CLIENT_SECRET
provider "hcp" { }

module "hcp_terraform_project_group_access" { 
  source                = "./project_group_access"
  organization_name     = "TFC-Unification-Test-Org-1"
  group_name            = "test-provider-group"
  project_name          = "test-provider-project"
  api_token_group_name  = "joey-test"
  role                  = "maintain"
}
