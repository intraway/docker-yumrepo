#!/usr/bin/env sh

CONTAINER_IP=$(ip addr show eth0 | awk '$1 == "inet" {gsub(/\/.*$/, "", $2); print $2}')
NGINX_PID=undef

trap '_exit' SIGINT SIGTERM EXIT

function _exit(){
    kill -- -$$
    exit 0
}

function printRepoConf(){
    echo -e "------------------------------------------------------\nAdd this config to '/etc/yum.repos.d/container.repo' on the Client:\n------------------------------------------------------"
    echo -e "\n\ncat << EOF > /etc/yum.repos.d/container.repo\n\
[container]\n\
name=Container Repo\n\
baseurl=http://${CONTAINER_IP}/\\\$releasever/\\\$basearch/\n\
gpgcheck=0\n\
EOF\n\n\n------------------------------------------------------"
    echo -e "Then run: yum --disablerepo=* --enablerepo=container <action> <package>\n------------------------------------------------------\n"
}

function createRepos(){
    echo -e "> Creating repository indexes... (repo maxdepth ${REPO_DEPTH})"
    find ${REPO_PATH} -type d -maxdepth ${REPO_DEPTH} -mindepth ${REPO_DEPTH} -exec createrepo_c {} \;
}

function serveRepos(){
    echo -e "> Serving repositories... (on http://0.0.0.0:${REPO_PORT})"
    sed -i "s/listen.*;$/listen ${REPO_PORT};/g" /etc/nginx/conf.d/repo.conf
    exec nginx &
}

printRepoConf
createRepos
serveRepos

inotifywait -m -r -e create -e delete -e delete_self --excludei '(repodata|.*xml)' ${REPO_PATH}/ |
while read path action file; do
    echo -e "> Repository content was changed..."
    createRepos
done