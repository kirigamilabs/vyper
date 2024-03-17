# @version >=0.3.9

interface IUniswapV2Factory:
    def getPair(tokenA: address, tokenB: address) -> address: view

interface IUniswapV2Pair:
    def token0() -> address: view
    def token1() -> address: view
    def getReserves() -> (uint256, uint256, uint256): view

@external
@view
def get_pair_from_factory(
    factory_address: address, 
    tokenA: address, 
    tokenB: address,
) -> address:
    assert tokenA != tokenB, "token addresses must be different!"
    return IUniswapV2Factory(factory_address).getPair(tokenA, tokenB)

@external
@view
def get_reserves_from_liquidity_pool(pool_address: address) -> (uint256, uint256):
    reserve0: uint256 = 0
    reserve1: uint256 = 0
    time_stamp: uint256 = 0
     
    reserve0, reserve1, time_stamp = IUniswapV2Pair(pool_address).getReserves()
    return reserve0, reserve1

@external
@view
def get_tokens_in_pool(pool_address:address) -> (address, address):
    return IUniswapV2Pair(pool_address).token0(), IUniswapV2Pair(pool_address).token1()

@external
@view
def get_reserves_by_pairs(pool_addresses: DynArray[address,1111]) -> (DynArray[uint256[3], 1111]):
    result: DynArray[uint256[3], 1111] = []
    rr: uint256[3] = empty(uint256[3])
    dalen: uint256 = 0
    dalen = len(pool_addresses)
    for i in range(1111):
        if i < dalen:
            rr[0],rr[1],rr[2] = IUniswapV2Pair(pool_addresses[i]).getReserves()
            result.append(rr)
        else:
            break
    return result