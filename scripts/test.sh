#!/usr/bin/env bash
set -e

[[ "$(cast chain --rpc-url="$ETH_RPC_URL")" == "ethlive" ]] || { echo "Please set a Mainnet ETH_RPC_URL"; exit 1; }

for ARGUMENT in "$@"
do
    KEY=$(echo "$ARGUMENT" | cut -f1 -d=)
    VALUE=$(echo "$ARGUMENT" | cut -f2 -d=)

    case "$KEY" in
            match-test)      MATCH_TEST="$VALUE" ;;
            match-contract)  MATCH_CONTRACT="$VALUE" ;;
            *)
    esac
done

if [[ -n "$MATCH_TEST" ]]; then
    forge test --fork-url "$ETH_RPC_URL" --match-test "$MATCH_TEST" -vvv --force
elif [[ -n "$MATCH_CONTRACT" ]]; then
    forge test --fork-url "$ETH_RPC_URL" --match-contract "$MATCH_CONTRACT" -vvv --force
else
    forge test --fork-url "$ETH_RPC_URL" --force -vvv
fi
