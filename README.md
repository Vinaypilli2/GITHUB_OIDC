## 🔐 GitHub OIDC with GCP Workload Identity Federation

This guide explains how to authenticate GitHub Actions to Google Cloud using **Workload Identity Federation (WIF)** and **OIDC**, eliminating the need for service account keys.



### 🛠️ Step-by-Step: Register GCP Workload Identity Provider with GitHub

#### 1. Enable IAM Credentials API


gcloud services enable iamcredentials.googleapis.com


---

#### 2. Create Workload Identity Pool


gcloud iam workload-identity-pools create "github-pool" \
  --location="global" \
  --display-name="GitHub Pool"

#### 3. Create Workload Identity Provider


gcloud iam workload-identity-pools providers create-oidc "github-provider" \
  --location="global" \
  --workload-identity-pool="github-pool" \
  --display-name="GitHub Provider" \
  --issuer-uri="https://token.actions.githubusercontent.com" \
  --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository"
```

---

#### 4. Create GCP Service Account


gcloud iam service-accounts create github-actions-sa \
  --display-name="GitHub Actions Service Account"
```

---

#### 5. Allow GitHub to Impersonate the Service Account


gcloud iam service-accounts add-iam-policy-binding github-actions-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/YOUR_PROJECT_NUMBER/locations/global/workloadIdentityPools/github-pool/attribute.repository/YOUR_GITHUB_USER_OR_ORG/YOUR_REPO"
```

Replace:

* `YOUR_PROJECT_ID` with your actual GCP project ID
* `YOUR_PROJECT_NUMBER` with your project number
* `YOUR_GITHUB_USER_OR_ORG/YOUR_REPO` with your GitHub repo path (e.g. `octocat/my-repo`)

---

#### 6. Grant Required Roles to the Service Account


gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:github-actions-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/storage.admin"
```

Add additional roles as needed:


# Example additional roles
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:github-actions-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/artifactregistry.writer"
```

---

#### 7. Get the Workload Identity Provider Resource Name


gcloud iam workload-identity-pools providers describe "github-provider" \
  --location="global" \
  --workload-identity-pool="github-pool" \
  --format="value(name)"
```

Example output:

```
projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/github-pool/providers/github-provider
```

---

### 🤖 GitHub Actions Integration

In your GitHub repository, go to **Settings > Secrets and variables > Actions > New repository secret**, and add the following:

| Secret Name                  | Description                           |
| ---------------------------- | ------------------------------------- |
| `GCP_PROJECT`                | Your GCP project ID                   |
| `GCP_SERVICE_ACCOUNT_EMAIL`  | Full email of the GCP service account |
| `WORKLOAD_IDENTITY_PROVIDER` | Output from step 7 above              |

---

#### Example `.github/workflows/deploy.yml`

```yaml
name: Deploy

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read

    steps:
      - uses: actions/checkout@v4

      - id: auth
        uses: google-github-actions/auth@v2
        with:
          token_format: 'access_token'
          workload_identity_provider: ${{ secrets.WORKLOAD_IDENTITY_PROVIDER }}
          service_account: ${{ secrets.GCP_SERVICE_ACCOUNT_EMAIL }}

      - name: Set up gcloud CLI
        uses: google-github-actions/setup-gcloud@v2
        with:
          project_id: ${{ secrets.GCP_PROJECT }}

      - name: List GCS Buckets
        run: |
          gcloud storage buckets list --project ${{ secrets.GCP_PROJECT }}
```
