![](./public/assets/kirigami-app-icon-192.png)

# Kirigami Labs - Vyper Examples

Welcome to Vyper examples from Kirigami Labs!

Homepage: [https://kirigamilabs.com](https://kirigamilabs.com)

We are building on the shoulders of giants and are proud to say that we leverage code and knowledge provided by those that came before us. 

Special thanks to the Ethereum and Vyper Lang organizations for providing amazing products and thank you specifically to Charles Cooper, pcaversaccio, and all others who have contributed to the development and growth of the Vyper language. 

## Kirigami Labs - Vyper References

- [Vyper Git](https://github.com/vyperlang/vyper)
- [Vyper Docs](https://docs.vyperlang.org/en/stable/toctree.html)
- [Vyper Resources](https://github.com/stars/pcaversaccio/lists/vyper) - A curated list of Vyper resources, libraries, tools, and more

- [Snekmate](https://github.com/pcaversaccio/snekmate) - State-of-the-art, highly opinionated, hyper-optimised, and secure 🐍 Vyper smart contract building blocks

- [Titanoboa](https://github.com/vyperlang/titanoboa) - a vyper interpreter

- [BowTiedDevil](https://substack.com/@degencode) - Self-taught coder, autistic cartoon, blockchain enthusiastic, technical writer (great resources to get started, search for Vyper posts)


- [MEW Contract Deployment](https://www.myetherwallet.com/wallet/deploy) - Simple contract deployment via My Ether Wallet

Once you are ready to deploy your Vyper contract, use the following commands to generate bytecode and abi from contracts folder:

➜  contracts vyper contract_name.vy

➜  contracts vyper -f abi contract_name.vy


## Code structure

| Folder                   | Primary use                                                                                     |
| ------------------------ | ----------------------------------------------------------------------------------------------- |
| `/src`                   | Main source folder for development                                                              |
| `/src/abi`               | ABI files for  **vyper** files in contracts folder                                              |
| `/src/bytecode`          | Bytecode files for  **vyper** files in contracts folder                                         |
| `/src/contracts`         | Contract files for **vyper**                                                                    |
| `/public`                | Storage for assets that will be available at URL path after build                               |
| `/public/assets`         | General image assets                                                                            |
| `/references`            | Reference files that were used in the development of example **vyper** contracts                |

## Contract Files:

Please note all example contracts are experimental and solely for educational purposes and advancement of the Vyper langugage. 

- `Univ2Data.vy` is a read-only contract that allows for pulling pairs, reserves, and tokens from Uniswap v2 pairs.

- `Univ3Data.vy` is a read-only contract that allows for pulling pools, liquidity, reserves, and tokens from Uniswap v3 pools.

- `BatchUniData.vy` is a batch contract that allows for pulling all relevant data in Uniswap v2 pairs and v3 pools (except for data outside tick ranges in Uniswap v3).


- `DexArbExecutor.vy` is a Uniswap dex arbitrage executor contract that utilizes off-chain data sourcing of arbitrage opportunities. This example does cyclical arbitrage with WETH and does not require funding of the contract to perform arbitrage. Contract utilizes the functions rpo2 and rpo3 for 2-pool and 3-pool arbitrage. 

### Variables for DexArbExecutor call:
- `flash: uint8` is a binary flag. If set to 1, it will use flash loan when dex arb cannot be done atomically without funds. 
- `amountIn: uint256`  is the amountIn in WETH (no decimals).
- `dex: uint8[]` is an array that flags whether pool is Uniswap v2 (value: 2) or Uniswap v3 (value: 3).
- `pool_address: address[]` is an array of pool addresses. 
- `amountOut: uint256[]` is an array of amountOuts of output token from pools (no decimals). 
- `zeroForOne: bool[]` is a boolean array labeling whether you are swapping from Token 0 to Token 1 (value: True) or from Token 1 to Token 0 (value: False) within the pool.

Example 2-pool arbitrage:
```
    DexArbExecutor.functions.rpo2(
        1,
        125000000000000000,
        [3, 2],
        ['0x65DC6065fF58d7B468e250F1037C575507c7A6a6', '0xF5C92780138061a113fd708d4b403E0E830effFf'],
        [120420203725456737495, 130155365790298005],
        [True, False]
        )
```

Example 3-pool arbitrage:
```
    DexArbExecutor.functions.rpo3(
        1,
        500000000000000000,
        [2, 3, 2],
        ['0x2cC846fFf0b08FB3bFfaD71f53a60B4b6E6d6482', '0x6e7F25cb3d281d64DbE4b1a38072836ADC11815F', '0x52c77b0CB827aFbAD022E6d6CAF2C44452eDbc39'],
        [1301765798543, 26483878580848, 505312605087474755],
        [False, True, False]
        )
```


### Example DexArbExecutor transaction call via web3.py: 
```
from web3 import Web3
from datetime import datetime

web3 = Web3(Web3.HTTPProvider("#")) #input provider address
contract_address = web3.to_checksum_address('#') #input contract address after deployment
contract_abi = #input abi 
contract = web3.eth.contract(address=contract_address, abi=contract_abi) # declaring the contract
nonce = web3.eth.get_transaction_count(account_address)
goflag = 0

tx_params = {
        'from': account_address,
        'value': 0, 
        #'value': web3.to_wei(0.000001, 'ether'),
        #'gas': 50000,
        'gasPrice': web3.to_wei(gas_price, 'gwei'),
        'nonce': nonce
    }

tx = DexArbExecutor.functions.rpo2(
    1,
    125000000000000000,
    [3, 2],
    ['0x65DC6065fF58d7B468e250F1037C575507c7A6a6', '0xF5C92780138061a113fd708d4b403E0E830effFf'],
    [120420203725456737495, 130155365790298005],
    [True, False]
    ).build_transaction(tx_params)

gas = web3.eth.estimate_gas(tx) #get transaction gas estimate

tx_params = {
        'from': account_address,
        'value': 0,
        #'value': web3.to_wei(0.000001, 'ether'),
        'gas': gas3,
        'gasPrice': web3.to_wei(gas_price, 'gwei'),
        'nonce': nonce
    }

testtx = contract.functions.rpo2(1, amountIn, dexes, pool_addresses, amountOuts, zeroForOnes).call(tx_params) #test transaction to ensure it doesn't fail

if goflag == 1:

    signed_tx = web3.eth.account.sign_transaction(tx, private_key)
    send_tx = web3.eth.send_raw_transaction(signed_tx.rawTransaction)
    tx_hash = web3.to_hex(send_tx)

    print('Transaction')
    print(tx_hash)

    #loop checking status of transaction
    blockhash = None
    status2 = None
    while blockhash == None:
        time.sleep(3)
        
        try:
            status = web3.eth.get_transaction(tx_hash)
            blockhash = status['blockHash']
        except:
            status = None
        
        print(str(datetime.now())+' - '+str(txhash))
        
        if status2 == status:
            print('Transaction pending...')
        else:
            print(status)
            status2 = status
        

    print('Transaction 3 Complete : '+str(datetime.now()))
```

Note 1: example calls are solely for demonstrative purposes and may fail given changing values in pools


Note 2: example web3.py files will be added later with onchain contracts for testing


## Inspiration

“No one is useless in this world,' retorted the Secretary, 'who lightens the burden of it for any one else.”

― Charles Dickens, Our Mutual Friend