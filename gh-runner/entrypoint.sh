#!/usr/bin/env bash
set -Eeuo pipefail

: "${GITHUB_OWNER:?Missing GITHUB_OWNER}"
: "${GITHUB_PAT:?Missing GITHUB_PAT}"

: "${RUNNER_NAME_PREFIX:=redtilt}"
: "${RUNNER_GROUP:=private-all}"
: "${RUNNER_LABELS:=portainer,docker}"
: "${RUNNER_WORKDIR:=_work}"
: "${EPHEMERAL:=true}"
: "${DISABLE_RUNNER_UPDATE:=true}"

GH_URL="https://github.com/${GITHUB_OWNER}"
REG_TOKEN_URL="https://api.github.com/orgs/${GITHUB_OWNER}/actions/runners/registration-token"
REMOVE_TOKEN_URL="https://api.github.com/orgs/${GITHUB_OWNER}/actions/runners/remove-token"

cd /actions-runner

get_token() {
  local url="$1"
  curl -fsSL -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer ${GITHUB_PAT}" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "${url}" | jq -r '.token'
}

cleanup() {
  echo "Cleaning up runner registration..."
  if [[ -f .runner ]]; then
    REMOVE_TOKEN="$(get_token "${REMOVE_TOKEN_URL}")" || true
    ./config.sh remove --unattended --token "${REMOVE_TOKEN}" || true
  fi
}
trap cleanup EXIT INT TERM

RUNNER_NAME="${RUNNER_NAME_PREFIX}-$(hostname)"
REG_TOKEN="$(get_token "${REG_TOKEN_URL}")"

EXTRA_ARGS=()
if [[ -n "${RUNNER_GROUP}" ]]; then
  EXTRA_ARGS+=(--runnergroup "${RUNNER_GROUP}")
fi
if [[ "${EPHEMERAL}" == "true" ]]; then
  EXTRA_ARGS+=(--ephemeral)
fi
if [[ "${DISABLE_RUNNER_UPDATE}" == "true" ]]; then
  EXTRA_ARGS+=(--disableupdate)
fi

./config.sh \
  --unattended \
  --replace \
  --name "${RUNNER_NAME}" \
  --url "${GH_URL}" \
  --token "${REG_TOKEN}" \
  --labels "${RUNNER_LABELS}" \
  --work "${RUNNER_WORKDIR}" \
  "${EXTRA_ARGS[@]}"

exec ./run.sh
