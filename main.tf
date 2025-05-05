provider "google" {
  project = "direct-outlet-458407-n6"
  region  = "us-central1"
}

resource "google_iam_workload_identity_pool" "github_pool" {
  workload_identity_pool_id = "github-pool"
  display_name              = "GitHub Pool"
  description               = "OIDC pool for GitHub Actions"
  location                  = "global"
}

resource "google_iam_workload_identity_pool_provider" "github_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  display_name                       = "GitHub Provider"
  description                        = "Allows GitHub Actions OIDC tokens"
  location                           = "global"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  attribute_mapping = {
    "google.subject"           = "assertion.sub"
    "attribute.repository"     = "assertion.repository"
    "attribute.actor"          = "assertion.actor"
    "attribute.aud"            = "assertion.aud"
  }

  attribute_condition = "assertion.repository == 'Vinaypilli2/GITHUB_OIDC'"
}
