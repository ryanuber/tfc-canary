variable "organization_name" {
  type = string
}

variable "organization_email" {
  type = string
}

variable "github_token" {
  type      = string
  sensitive = true
}

resource "tfe_organization" "canary" {
  name                    = var.organization_name
  email                   = var.organization_email
  cost_estimation_enabled = true
}

resource "tfe_oauth_client" "github" {
  organization     = tfe_organization.canary.name
  api_url          = "https://api.github.com"
  http_url         = "https://github.com"
  oauth_token      = var.github_token
  service_provider = "github"
}

resource "tfe_workspace" "canary" {
  name                = "canary"
  organization        = tfe_organization.canary.name
  auto_apply          = true
  speculative_enabled = false
  terraform_version   = "latest"
  working_directory   = "terraform/canary"
  vcs_repo {
    identifier     = "ryanuber/tfc-canary"
    oauth_token_id = tfe_oauth_client.github.oauth_token_id
  }
}

resource "tfe_variable" "canary_name" {
  key          = "name"
  value        = "foobar"
  category     = "terraform"
  workspace_id = tfe_workspace.canary.id
}

# Requires entitlement.
#resource "tfe_policy_set" "default" {
#  name          = "default"
#  organization  = tfe_organization.canary.name
#  policies_path = "sentinel"
#  workspace_ids = [tfe_workspace.canary.id]
#  vcs_repo {
#    identifier     = "ryanuber/tfc-canary"
#    oauth_token_id = tfe_oauth_client.github.oauth_token_id
#  }
#}
