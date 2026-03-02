all        :; forge build
clean      :; forge clean
test       :; forge test --fork-url ${ETH_RPC_URL} --force -vvv
deploy     :; forge create src/MegaPoker.sol:MegaPoker --rpc-url $(ETH_RPC_URL) --keystore $(ETH_KEYSTORE)
