resource "google_service_account" "github_sa" {
  account_id   = "github-actions-sa"
  display_name = "GitHub Actions Service Account"
}

resource "google_service_account_iam_binding" "github_wif_binding" {
  service_account_id = google_service_account.github_sa.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "principalSet://iam.googleapis.com/projects/827812434085/locations/global/workloadIdentityPools/github-pool/attribute.repository/Vinaypilli2/GITHUB_OIDC"
  ]
}
