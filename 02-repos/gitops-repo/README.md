# GitOps Repo (Student Thesis)

Repo nay dung de quan ly manifests trien khai cho Argo CD.

## Muc tieu

- Luu Helm/Kustomize manifests theo moi truong.
- Nhan image tag moi do CI cap nhat tu App Repo.
- Argo CD se theo doi repo nay va sync vao EKS.

## De xuat cau truc

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

## Nguyen tac

- Khong commit secret thuan van ban.
- Moi thay doi image tag phai qua commit ro rang.
- Rollback thong qua `git revert`.
