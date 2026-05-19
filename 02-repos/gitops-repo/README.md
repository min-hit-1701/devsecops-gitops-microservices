# GitOps Repo (Student Thesis)

This repo is used to manage deployment manifests for Argo CD.

## Objective

- Store Helm/Kustomize manifests per environment.
- Receive new image tags updated by CI from the App Repo.
- Argo CD will watch this repo and sync into EKS.

## Proposed Structure

```text
gitops-repo/
  apps/
    retail-store/
      base/
      overlays/
        dev/
        staging/
        prod/
  argocd/
    projects/
    applications/
```

## Principles

- Do not commit secrets in plain text.
- Every image tag change must go through a clear commit.
- Rollback via `git revert`.
