resource "google_iam_workload_identity_pool" "github_pool" {
  project        = "direct-outlet-458407-n6"
  location       = "global"
  workload_identity_pool_id = "github-pool"
  display_name   = "GitHub Pool"
  description    = "OIDC pool for GitHub Actions"
}

resource "google_iam_workload_identity_pool_provider" "github_provider" {
  project                            = "direct-outlet-458407-n6"
  location                           = "global"
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"

  display_name = "GitHub OIDC Provider"
  description  = "OIDC provider for GitHub Actions"

  attribute_mapping = {
    "google.subject"         = "assertion.sub"
    "attribute.actor"        = "assertion.actor"
    "attribute.repository"   = "assertion.repository"
  }

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  attribute_condition = "assertion.repository == 'Vinaypilli2/GITHUB_OIDC'"
}
