import git

class RepositoryFacade:
    @staticmethod
    def handle_upload(repo_name, uploaded_file):
        # Save uploaded file to a directory in PVC (mounted at /data/repos)
        upload_path = f'/data/repos/{repo_name}'
        with open(upload_path, 'wb+') as dest:
            dest.write(uploaded_file.read())
        return upload_path

    @staticmethod
    def clone_repo_from_url(repo_name, repo_url):
        # Clone the repository to PVC mounted directory
        clone_path = f'/data/repos/{repo_name}'
        git.Repo.clone_from(repo_url, clone_path)
        return clone_path
