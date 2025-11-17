# WordPress Plugin/Theme Deployment Action

This GitHub Action allows you to easily deploy WordPress plugins or themes directly from GitHub to your WordPress server using an SSH private key and the rsync command.

By default, the action deploys the repository's root directory. However, you can optionally deploy a specific directory using the `SRC_PATH` option. The `REMOTE_PATH` specifies where to deploy on the server. If a `.deployignore` file exists in the source path, it will be automatically used to exclude files and directories from deployment, and cleanup will be enabled to remove any files from the server that are not present in the source. Without a `.deployignore` file, only basic exclusions (dot files) apply and no cleanup occurs.

## GitHub Action workflow

1. **Set up your SSH key on your server:** Ensure the SSH key required for deployment is properly set up and accessible on your server.

2. **Create a workflow file:** In the root directory of your repository, navigate to `.github/workflows/` and create a new YML file. You can name it anything you like, such as `deploy.yml`.

## YAML Configuration Examples

Here are several examples of how to configure the WordPress Deploy Action for different scenarios:

### Basic Plugin Deployment

```yml
name: 🚀 Deploy WordPress Plugin
on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: 📥 Checkout code
        uses: actions/checkout@v4

      - name: 🚀 Deploy to Production
        uses: MrTrilB/wordpress-deploy@latest
        with:
          SSH_PRIVATE_KEY: ${{ secrets.SSH_PRIVATE_KEY }}
          SERVER_HOST: ${{ secrets.SERVER_HOST }}
          SERVER_USER: ${{ secrets.SERVER_USER }}
          REMOTE_PATH: ${{ secrets.REMOTE_PATH }}
```

### Plugin Deployment with .deployignore (Recommended)

*See the "Ignoring files" section below for details on creating a `.deployignore` file.*

```yml
name: 🚀 Deploy WordPress Plugin
on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: 📥 Checkout code
        uses: actions/checkout@v4

      - name: 🔍 Run PHP Linting
        uses: MrTrilB/wordpress-deploy@latest
        with:
          SSH_PRIVATE_KEY: ${{ secrets.SSH_PRIVATE_KEY }}
          SERVER_HOST: ${{ secrets.SERVER_HOST }}
          SERVER_USER: ${{ secrets.SERVER_USER }}
          REMOTE_PATH: ${{ secrets.REMOTE_PATH }}
          PHP_LINT: true
```

### Theme Deployment with Custom Path

```yml
name: 🎨 Deploy WordPress Theme
on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: 📥 Checkout code
        uses: actions/checkout@v4

      - name: 🎨 Deploy Theme
        uses: MrTrilB/wordpress-deploy@latest
        with:
          SSH_PRIVATE_KEY: ${{ secrets.SSH_PRIVATE_KEY }}
          SERVER_HOST: ${{ secrets.SERVER_HOST }}
          SERVER_USER: ${{ secrets.SERVER_USER }}
          REMOTE_PATH: /var/www/html/wp-content/themes/my-custom-theme
          SRC_PATH: theme-files  # Deploy from specific directory
          PHP_LINT: true
          CACHE_CLEAR: true
```

### Full-Featured Deployment

```yml
name: 🚀 Full Deployment with All Features
on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: 📥 Checkout code
        uses: actions/checkout@v4

      - name: 🚀 Deploy with All Options
        uses: MrTrilB/wordpress-deploy@latest
        with:
          SSH_PRIVATE_KEY: ${{ secrets.SSH_PRIVATE_KEY }}
          SERVER_HOST: ${{ secrets.SERVER_HOST }}
          SERVER_USER: ${{ secrets.SERVER_USER }}
          REMOTE_PATH: ${{ secrets.REMOTE_PATH }}
          SRC_PATH: .  # Deploy from repository root
          FLAGS: -azvrhi --inplace  # Custom rsync flags
          PHP_LINT: true  # Enable PHP syntax checking
          CACHE_CLEAR: true  # Clear WordPress cache after deployment
          SCRIPT: scripts/post-deploy.sh  # Run custom script on server
```

### Staging and Production Deployment

```yml
name: 🚀 Deploy to Multiple Environments
on:
  push:
    branches: [main, develop]
  workflow_dispatch:

jobs:
  deploy-staging:
    if: github.ref == 'refs/heads/develop'
    runs-on: ubuntu-latest
    environment: staging
    steps:
      - name: 📥 Checkout code
        uses: actions/checkout@v4

      - name: 🧪 Deploy to Staging
        uses: MrTrilB/wordpress-deploy@latest
        with:
          SSH_PRIVATE_KEY: ${{ secrets.STAGING_SSH_PRIVATE_KEY }}
          SERVER_HOST: ${{ secrets.STAGING_SERVER_HOST }}
          SERVER_USER: ${{ secrets.STAGING_SERVER_USER }}
          REMOTE_PATH: ${{ secrets.STAGING_REMOTE_PATH }}
          PHP_LINT: true

  deploy-production:
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    environment: production
    steps:
      - name: 📥 Checkout code
        uses: actions/checkout@v4

      - name: 🚀 Deploy to Production
        uses: MrTrilB/wordpress-deploy@latest
        with:
          SSH_PRIVATE_KEY: ${{ secrets.SSH_PRIVATE_KEY }}
          SERVER_HOST: ${{ secrets.SERVER_HOST }}
          SERVER_USER: ${{ secrets.SERVER_USER }}
          REMOTE_PATH: ${{ secrets.REMOTE_PATH }}
          PHP_LINT: true
          CACHE_CLEAR: true
```

## Quick Start

1. **Set up your SSH key** following the instructions in the "Setting up your SSH key" section below.

2. **Create a workflow file** at `.github/workflows/deploy.yml` in your repository.

3. **Choose an example** from the YAML Configuration Examples section above that matches your needs.

4. **Configure secrets** in your repository settings with your SSH credentials and server details.

5. **Push your changes** to trigger the deployment!

## Deploying from a specific branch or tag

To deploy from a specific branch, tag, or commit SHA, modify the checkout step in your workflow to specify the ref:

```yml
- name: 🚚 Getting latest code
  uses: actions/checkout@v4
  with:
    ref: 'your-branch-name'  # or 'v1.0.0' for a tag, or a commit SHA
```

You can also use the `REF` input to make it configurable, but ensure the checkout step uses the desired reference.

## Ignoring files

If you want to exclude certain files or directories from being deployed, you can create a `.deployignore` file in your source directory. In this file, you can specify patterns of files and directories to exclude—one pattern per line. Blank lines and lines starting with `#` will be ignored. The `.deployignore` file is automatically used if it exists in the source path, and cleanup will be enabled to remove any files from the server that are not present in the source.

### Example `.deployignore` file

```ignore
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

The action automatically uses the `.deployignore` file if present in the source path. When found, it:

- Excludes the specified files/patterns from deployment

- Enables cleanup to remove files from the server that aren't in the source

No additional configuration is needed in the `FLAGS` option.

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
| `FLAGS`       | _string_ | Rsync flags. Defaults to `-azvrhi --inplace --exclude='.*'`. When `.deployignore` exists, `--exclude-from` and `--delete` are automatically added. |
| `PHP_LINT`    | _string_ | Set to `true` to enable PHP linting. Defaults to `false`.             |
| `CACHE_CLEAR` | _string_ | Set to `true` to clear WordPress cache. Defaults to `false`.          |
| `SCRIPT`      | _string_ | Custom script to run on the remote server after deployment.          |

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
