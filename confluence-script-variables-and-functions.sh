#!/usr/bin/env bash

INDEX_USER=rebuild-index
INDEX_PASSWORD=rebuild-index

APACHE_SERVICE=httpd
APACHE_CACHE_LOCATION_HTTP=/diskcache/http
APACHE_CACHE_LOCATION_HTTPS=/diskcache/https

CONFLUENCE_SERVICE=confluence
CONFLUENCE_HOME=/var/atlassian/application-data/confluence


CONFLUENCE_BASE_URL="http://127.0.0.1:8090"

CONFLUENCE_LOGIN_URL="$CONFLUENCE_BASE_URL/login.action"
CONFLUENCE_REBUILD_INDEX_URL="$CONFLUENCE_BASE_URL/rest/prototype/1/index/reindex"

EXPECTED_HTTP_STATUS=200


# Connection check and retry configuration
# ########################################
#
# Max retry time is: $RETRYS_BEFORE_FAILURE * ($CURL_TIMEOUT + $SLEEP_BEFORE_RETRY)
#
# If the server responds quickly but not with the $EXPECTED_HTTP_STATUS then the retry time is at least $RETRYS_BEFORE_FAILURE * $SLEEP_BEFORE_RETRY
#
# Example configuration with max 10 minutes (600 seconds) retries and at least 5 minutes.
#
# CURL_TIMEOUT=5
# SLEEP_BEFORE_RETRY=5
# RETRYS_BEFORE_FAILURE=60

CURL_TIMEOUT=5
SLEEP_BEFORE_RETRY=5
DEFAULT_RETRIES_BEFORE_FAILURE=60

# FUNCTIONS
# #########

function exit_with_error {
	ERROR_MESSAGE=$1
	echo ""
	(>&2 echo $ERROR_MESSAGE)
	exit 1
}

function run_request_with_retries {
	COUNTER=1;
	HTTP_STATUS=0
	REQUEST_COMMAND=$1

	RETRIES=$2

	if [ -z "$RETRIES" ]; then
		RETRIES=$DEFAULT_RETRIES_BEFORE_FAILURE
	fi

	while [ $COUNTER -le $RETRIES ] && [ $HTTP_STATUS != $EXPECTED_HTTP_STATUS ];
	do
		sleep $SLEEP_BEFORE_RETRY;
		HTTP_STATUS=$($REQUEST_COMMAND)

		echo "HTTP_STATUS: $HTTP_STATUS ($COUNTER/$RETRIES)"
		COUNTER=$[$COUNTER + 1];
	done
}
