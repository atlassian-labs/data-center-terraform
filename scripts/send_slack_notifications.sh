#!/bin/bash
set -e

COMMIT="<https://github.com/$GITHUB_REPOSITORY/commit/${GITHUB_SHA}|${GITHUB_SHA}>"
SOURCE="branch: <https://github.com/$GITHUB_REPOSITORY/tree/${GITHUB_REF_NAME}|${GITHUB_REF_NAME}>"

if [ ${GITHUB_EVENT_NAME} == "pull_request" ]; then
  SOURCE="pr: <${PULL_REQUEST_URL}|${PULL_REQUEST_TITLE}>"
  COMMIT="<https://github.com/${GITHUB_REPOSITORY}/pull/${GITHUB_EVENT_NUMBER}/commits/${GITHUB_SHA}|${GITHUB_SHA}>"
fi

if [[ ${JOB_STATUS} == "success" ]]; then
  ICON=":white_check_mark:"
  COLOR="#00cc00"
elif [[ ${JOB_STATUS} == "failure" ]]; then
  ICON=":red_circle:"
  COLOR="#cc0000"
else
  # assume it's cancelled
  ICON=":white_circle:"
  COLOR="#808080"
fi

PAYLOAD="{\"attachments\": [{\"color\":\"${COLOR}\",\"blocks\":[{\"type\":\"section\",\"text\":{\"type\":\"mrkdwn\",\"text\":\"${ICON} Workflow <https://github.com/$GITHUB_REPOSITORY/actions/runs/${GITHUB_RUN_ID}|${GITHUB_WORKFLOW}> has completed with result: *${JOB_STATUS}*\n• commit: ${COMMIT}\n• ${SOURCE}\n• event: ${GITHUB_EVENT_NAME} \n• triggered by: ${GITHUB_ACTOR}\"}}]}]}"

curl -s -X POST ${SLACK_WEBHOOK_URL} -H 'Content-type: application/json' -d "${PAYLOAD}"
