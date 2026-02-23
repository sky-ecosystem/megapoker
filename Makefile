all        :; forge build
clean      :; forge clean
test       :; ./scripts/test.sh match-test="$(match-test)" match-contract="$(match-contract)"
deploy     :; forge create src/MegaPoker.sol:MegaPoker --rpc-url $(ETH_RPC_URL) --keystore $(ETH_KEYSTORE)
