#!/usr/bin/env python3
"""
Script cập nhật GitOps repo với image tag mới từ CI pipeline.
Chạy sau khi build và push ECR thành công.

Usage:
    python3 update-gitops-repo.py \
        --gitops-repo-url <url> \
        --gitops-repo-path /tmp/gitops-repo \
        --services ui,cart,orders,catalog,checkout \
        --image-tag abc1234 \
        --ecr-base-url <AWS_ACCOUNT_ID>.dkr.ecr.<AWS_REGION>.amazonaws.com
"""

import argparse
import os
import subprocess
import sys
import yaml


def clone_or_pull(repo_url, repo_path):
    if os.path.isdir(repo_path):
        subprocess.run(['git', '-C', repo_path, 'pull', 'origin', 'HEAD'], check=True)
    else:
        subprocess.run(['git', 'clone', repo_url, repo_path], check=True)


def update_image_tags(repo_path, services, image_tag, ecr_base_url, env_name):
    for svc in services:
        image_name = f"{ecr_base_url}/{env_name}-{svc}"

        for root, dirs, files in os.walk(os.path.join(repo_path, 'apps')):
            for fname in files:
                if fname == 'kustomization.yaml':
                    filepath = os.path.join(root, fname)
                    try:
                        with open(filepath, 'r') as f:
                            docs = list(yaml.safe_load_all(f))

                        updated = False
                        for doc in docs:
                            if not doc or 'images' not in doc:
                                continue
                            for img in doc['images']:
                                if img.get('name') == svc or img.get('newName') == image_name:
                                    img['newTag'] = image_tag
                                    updated = True
                                    print(f"  Updated {svc} -> {image_tag} in {filepath}")

                        if updated:
                            with open(filepath, 'w') as f:
                                yaml.dump_all(docs, f, default_flow_style=False)
                    except Exception as e:
                        print(f"  Warning: Could not process {filepath}: {e}")


def commit_and_push(repo_path, image_tag):
    subprocess.run(['git', '-C', repo_path, 'config', 'user.email', 'ci-bot@devsecops.local'], check=True)
    subprocess.run(['git', '-C', repo_path, 'config', 'user.name', 'CI Bot'], check=True)

    result = subprocess.run(['git', '-C', repo_path, 'diff', '--quiet'], capture_output=True)
    if result.returncode == 0:
        print("No changes to commit in GitOps repo.")
        return False

    subprocess.run(['git', '-C', repo_path, 'add', '.'], check=True)
    subprocess.run(['git', '-C', repo_path, 'commit', '-m', f'ci: update image tags to {image_tag} [skip ci]'], check=True)
    subprocess.run(['git', '-C', repo_path, 'push', 'origin', 'HEAD'], check=True)
    print(f"GitOps repo updated with tag: {image_tag}")
    return True


def main():
    parser = argparse.ArgumentParser(description='Update GitOps repo with new image tags')
    parser.add_argument('--gitops-repo-url', required=True)
    parser.add_argument('--gitops-repo-path', required=True)
    parser.add_argument('--services', required=True, help='Comma-separated service names')
    parser.add_argument('--image-tag', required=True)
    parser.add_argument('--ecr-base-url', required=True)
    parser.add_argument('--env-name', default='uit-devsecops-dev')
    args = parser.parse_args()

    services = [s.strip() for s in args.services.split(',')]

    print(f"[1/3] Cloning GitOps repo: {args.gitops_repo_url}")
    clone_or_pull(args.gitops_repo_url, args.gitops_repo_path)

    print(f"[2/3] Updating image tags for services: {services}")
    update_image_tags(args.gitops_repo_path, services, args.image_tag, args.ecr_base_url, args.env_name)

    print(f"[3/3] Committing and pushing changes...")
    commit_and_push(args.gitops_repo_path, args.image_tag)


if __name__ == '__main__':
    main()
