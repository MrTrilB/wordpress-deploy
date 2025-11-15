FROM instrumentisto/rsync-ssh:latest

LABEL "com.github.actions.name"="WordPress Plugin/Theme Deployment Action"
LABEL "com.github.actions.description"="Deploy WordPress plugins or themes from GitHub to a server using SSH and rsync"
LABEL "com.github.actions.color"="purple"
LABEL "com.github.actions.icon"="wordpress"
LABEL "repository"="https://github.com/yourusername/wp-deploy-action"
LABEL "maintainer"="MrTrilB <mrtrilb@trilb.dev>"

RUN apk add bash php
ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]