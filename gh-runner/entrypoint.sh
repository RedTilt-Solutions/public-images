#!/usr/bin/env bash
set -euo pipefail

: "${GITHUB_OWNER:?Missing GITHUB_OWNER}"
: "${GITHUB_PAT:?Missing GITHUB_PAT}"

: "${RUNNER_NAME_PREFIX:=portainer-org}"
: "${RUNNER_LABELS:=portainer,docker}"
: "${RUNNER_WORKDIR:=_work}"
: "${EPHEMERAL:=false}"

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
    "${url}" | jq -r .token
}

cleanup() {
  echo "Removing runner..."
  if [[ -f .runner ]]; then
    REMOVE_TOKEN="$(get_token "${REMOVE_TOKEN_URL}")" || true
    ./config.sh remove --unattended --token "${REMOVE_TOKEN}" || true
  fi
}
trap cleanup EXIT INT TERM

RUNNER_NAME="${RUNNER_NAME_PREFIX}-$(hostname)"
REG_TOKEN="$(get_token "${REG_TOKEN_URL}")"

EXTRA_ARGS=()
if [[ -n "${RUNNER_GROUP:-}" ]]; then
  EXTRA_ARGS+=(--runnergroup "${RUNNER_GROUP}")
fi
if [[ "${EPHEMERAL}" == "true" ]]; then
  EXTRA_ARGS+=(--ephemeral)
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
