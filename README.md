# WordPress Plugin/Theme Deployment Action

This GitHub Action allows you to easily deploy WordPress plugins or themes directly from GitHub to your WordPress server using an SSH private key and the rsync command.

By default, the action deploys the repository's root directory. However, you can optionally deploy a specific directory using the `SRC_PATH` option. The `REMOTE_PATH` specifies where to deploy on the server. If a `.deployignore` file exists in the source path, it will be automatically used to exclude files and directories from deployment.

You can enable cache purging with the `CACHE_CLEAR` flag and perform PHP syntax checks using the `PHP_LINT` flag. Additionally, custom commands can be executed on the server side by defining them with the `SCRIPT` option. The `CLEANUP` option allows removing files and folders from the server that are not part of the deployment, with a preview of what will be removed.

## GitHub Action workflow

1. **Set up your SSH key on your server:** Ensure the SSH key required for deployment is properly set up and accessible on your server.

2. **Create a workflow file:** In the root directory of your repository, navigate to `.github/workflows/` and create a new YML file. You can name it anything you like, such as `deploy.yml`.

3. **Add the workflow configuration:** Copy and paste the following code into your new YML file. Be sure to replace the placeholders with the appropriate values for your deployment environment. You can also specify which branches will trigger this action by editing the branches section of the YML file:

   ```yml
   name: 📦 Deploy to Production
   on:
      push:
         branches:
            - main
      workflow_dispatch:

   jobs:
      deploy:
         name: 🚩 Deployment Job
         runs-on: ubuntu-latest
         steps:
         - name: 🚚 Getting latest code
           uses: actions/checkout@v4

         - name: 🔁 Starting Deployment
           uses: MrTrilB/wordpress-deploy@latest
           with:
               SSH_PRIVATE_KEY: ${{ secrets.SSH_PRIVATE_KEY }}
               SERVER_HOST: your.server.com
               SERVER_USER: youruser
               REMOTE_PATH: /path/to/wp-content/plugins/your-plugin
               FLAGS: -azvrhi --inplace --delete --delete-excluded
               SCRIPT: bin/post-deploy.sh
               PHP_LINT: true
               CACHE_CLEAR: true
               CLEANUP: true
   ```

4. **Push changes to trigger the action:** After editing and saving the file, push the latest changes to your repository. The GitHub Action will automatically execute and handle the deployment process.

## Deploying from a specific branch or tag

To deploy from a specific branch, tag, or commit SHA, modify the checkout step in your workflow to specify the ref:

```yml
- name: 🚚 Getting latest code
  uses: actions/checkout@v4
  with:
    ref: 'your-branch-name'  # or 'v1.0.0' for a tag, or a commit SHA
```

You can also use the `REF` input to make it configurable, but ensure the checkout step uses the desired reference.

## Setting up your SSH key

1. **Generate a new SSH key pair:** Create a new SSH key pair to be used as a deploy key between your GitHub repository and your server. Generate a key pair with a blank passphrase. You can do this with the following command: `ssh-keygen -t rsa -b 4096 -C "your_email@example.com"`

2. **Add the public SSH key:** Copy the contents of the public key (the file ending in .pub) and add it to your server's authorized_keys file or SSH configuration.

3. **Store the private key in GitHub:** In your GitHub repository, navigate to `Settings > Secrets and variables > Actions`, and create a new encrypted secret with the private key content.

4. **Reference the private key in your workflow YML file:** In your GitHub Action workflow file, configure the SSH private key by referencing the secret you created.

## Environment variables

This action requires or supports the following variables:

### Required

| Name              | Type      | Usage                                                                 |
| ----------------- | --------- | --------------------------------------------------------------------- |
| `SSH_PRIVATE_KEY` | _secrets_ | The private SSH key. This must be stored in GitHub Secrets.           |
| `SERVER_HOST`     | _string_  | The SSH host of the server.                                           |
| `SERVER_USER`     | _string_  | The SSH username.                                                     |
| `REMOTE_PATH`     | _string_  | The remote path on the server where files should be deployed.        |

### Optional

| Name          | Type     | Usage                                                                 |
| ------------- | -------- | --------------------------------------------------------------------- |
| `REF`         | _string_ | The git reference (branch, tag, or commit SHA) to deploy from. Modify the checkout step to use this ref. |
| `SRC_PATH`    | _string_ | Local path to the source files for deployment. Defaults to `.`.       |
| `FLAGS`       | _string_ | Rsync flags. Defaults to `-azvrhi --inplace --exclude='.*'`.          |
| `PHP_LINT`    | _string_ | Set to `true` to enable PHP linting. Defaults to `false`.             |
| `CACHE_CLEAR` | _string_ | Set to `true` to clear WordPress cache. Defaults to `false`.          |
| `CLEANUP`     | _string_ | Set to `true` to remove files and folders from the server that are not present in the deployment source. When enabled, a preview of files to be removed will be shown before the actual cleanup. Defaults to `false`. |
| `SCRIPT`      | _string_ | Custom script to run on the remote server after deployment.          |

## Ignoring files

If you want to exclude certain files or directories from being deployed, you can create a `.deployignore` file in your source directory. In this file, you can specify patterns of files and directories to exclude—one pattern per line. Blank lines and lines starting with `#` will be ignored. The `.deployignore` file is automatically used if it exists in the source path.

### Example `.deployignore` file

```
.*
composer*
dist
node_modules
package*
phpcs*
src
vendor
```

### Configuring rsync with `.deployignore`

The action automatically uses the `.deployignore` file if present. No additional configuration is needed in the `FLAGS` option.

## Rsync option flags

| Flag              | Description                                                                 |
| ----------------- | --------------------------------------------------------------------------- |
| `-a` archive      | Enables archive mode, preserving permissions, timestamps, etc.             |
| `-z` compress     | Compresses file data during transfer.                                      |
| `-v` verbose      | Enables verbose output.                                                    |
| `-r` recursive    | Recursively copies directories.                                            |
| `-i` itemized     | Provides detailed list of changes.                                         |
| `--inplace`       | Updates files in place.                                                    |
| `--delete`        | Deletes files from destination that no longer exist in source.             |
| `--exclude`       | Excludes specific files.                                                   |
| `--exclude-from`  | Specifies a file containing exclusion patterns.                            |
| `-h` human-readable | Displays sizes in human-readable formats.                                |

## Contributing

Contributions are welcome!

## License

MIT