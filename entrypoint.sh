#!/bin/bash -l
set -e

# Validate the required environment variables
validate() {
	: ${SSH_PRIVATE_KEY:?"SSH_PRIVATE_KEY variable missing from environment variables."}
	: ${SERVER_HOST:?"SERVER_HOST variable missing from environment variables."}
	: ${SERVER_USER:?"SERVER_USER variable missing from environment variables."}
	: ${REMOTE_PATH:?"REMOTE_PATH variable missing from environment variables."}
	SRC_PATH="${SRC_PATH:-"."}"
	FLAGS="${FLAGS:-"-azvrhi --inplace --exclude='.*'"}"
	PHP_LINT="${PHP_LINT:-"false"}"
	CACHE_CLEAR="${CACHE_CLEAR:-"false"}"
	CLEANUP="${CLEANUP:-"false"}"
	SCRIPT="${SCRIPT:-""}"
}

# Set up environment variables
init() {
	SSH_HOST="${SERVER_HOST}"
	SSH_USER="${SERVER_USER}"
	SERVER_DEST="${SSH_USER}@${SSH_HOST}:${REMOTE_PATH}"

	parse_flags "$FLAGS"

	if [ -f "${SRC_PATH}/.deployignore" ]; then
		FLAGS_ARRAY+=("--exclude-from=${SRC_PATH}/.deployignore")
	fi

	if [ "${CLEANUP^^}" == "TRUE" ]; then
		FLAGS_ARRAY+=("--delete")
	fi

	print_info
	setup_ssh
	check_lint
}

# Print deployment info
print_info() {
	echo "--- DEPLOYMENT INFO ---"
	echo "* Server Host: ${SERVER_HOST}"
	echo "* Server User: ${SERVER_USER}"
	echo "* Source path: ${SRC_PATH}"
	echo "* Destination path: ${SERVER_DEST}"
	echo "* Flags: ${FLAGS_ARRAY[@]}"
	echo "* PHP linting: ${PHP_LINT}"
	echo "* Cache clear: ${CACHE_CLEAR}"
	echo "* Cleanup: ${CLEANUP}"
	echo "* Post-deploy script: ${SCRIPT}"
	echo "-----------------------"
}

# Parse flags into an array
parse_flags() {
	local flags="$1"
	FLAGS_ARRAY=()
	while IFS= read -r -d '' flag; do FLAGS_ARRAY+=("$flag"); done < <(echo "$flags" | xargs printf '%s\0')
}

# Set up SSH keys based on the provided private key
setup_ssh() {
	echo "Setting SSH path..."
	SSH_PATH="${HOME}/.ssh"
	if [ ! -d "${HOME}/.ssh" ]; then
		mkdir "${HOME}/.ssh"
		mkdir "${SSH_PATH}/ctl/"
		chmod -R 700 "$SSH_PATH"
	fi
	SSH_KEY_PATH="${SSH_PATH}/deploy_key"
	umask 077
	echo "${SSH_PRIVATE_KEY}" >"${SSH_KEY_PATH}"
	chmod 600 "${SSH_KEY_PATH}"
	KNOWN_HOSTS_PATH="${SSH_PATH}/known_hosts"
	ssh-keyscan -t rsa "${SSH_HOST}" >>"${KNOWN_HOSTS_PATH}"
	chmod 644 "${KNOWN_HOSTS_PATH}"
}

# Check PHP linting
check_lint() {
	if [ "${PHP_LINT^^}" == "TRUE" ]; then
		echo "Starting PHP linting..."
		find "${SRC_PATH}" -name "*.php" -type f -print0 | while IFS= read -r -d '' file; do
			php -l "$file"
			status=$?
			if [ $status -ne 0 ]; then
				echo "FAILURE: Linting failed - $file"
				exit 1
			fi
		done
		echo "PHP linting completed successfully."
	else
		echo "Skipping PHP linting."
	fi
}

# Sync files to the server using rsync and execute post-deploy script
sync_files() {
	SSH_SETTINGS="-v -p 22 -i ${SSH_KEY_PATH} -o StrictHostKeyChecking=no -o ControlPath='${SSH_PATH}/ctl/%C'"

	#create multiplex connection
	ssh -nNf ${SSH_SETTINGS} -o ControlMaster=yes "${SSH_USER}"
	echo "Multiplex SSH connection established."

	# Preview files to be removed if cleanup is enabled
	if [ "${CLEANUP^^}" == "TRUE" ]; then
		echo "Previewing files and folders to be removed..."
		set -x
		rsync --rsh="ssh ${SSH_SETTINGS}" \
			"${FLAGS_ARRAY[@]}" --dry-run \
			"${SRC_PATH}/" "${SERVER_DEST}"
		set +x
		echo "Preview complete. Starting actual deployment..."
	fi

	# Sync files to Server
	set -x
	rsync --rsh="ssh ${SSH_SETTINGS}" \
		"${FLAGS_ARRAY[@]}" --chmod=D775,F664 \
		"${SRC_PATH}/" "${SERVER_DEST}"
	set +x

	check_script
	check_cache

	# Execute post-deploy script
	ssh ${SSH_SETTINGS} "${SSH_USER}" "${SCRIPT_COMMAND} ${CACHE_COMMAND}"

	# Close SSH multiplex connection
	ssh -O exit -o ControlPath="${SSH_PATH}/ctl/%C" "${SSH_USER}"
	echo "✅ Site has been deployed!"
}

# Check if post-deploy script exists and set permissions
check_script() {
	if [ -n "${SCRIPT}" ]; then
		SCRIPT_PATH="${REMOTE_PATH}/${SCRIPT}"
		SCRIPT_COMMAND="bash ${SCRIPT_PATH}"
		echo "Script command: " ${SCRIPT_COMMAND}

		# Set permissions
		ssh ${SSH_SETTINGS} "${SSH_USER}" "chmod +x ${SCRIPT_PATH}"

		# Does file exist?
		ssh ${SSH_SETTINGS} "${SSH_USER}" "if [ -f ${SCRIPT_PATH} ]; then echo 'Script file found'; else echo 'Script file not found'; fi"
	fi
}

# Check cache clearing command
check_cache() {
	if [ "${CACHE_CLEAR^^}" == "TRUE" ]; then
		CACHE_COMMAND="&& wp --skip-plugins --skip-themes cache flush"
		echo "Cache command: " ${CACHE_COMMAND}
	else
		CACHE_COMMAND=""
	fi
}

# Main execution
validate
init
sync_files