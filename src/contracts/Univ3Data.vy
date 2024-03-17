# @version >=0.3.9

interface IUniswapV3Pool:
    def token0() -> address: view
    def token1() -> address: view
    def liquidity() -> uint128: view
    def slot0() -> (uint160, int24, uint16, uint16, uint16, uint8, bool): view
    def ticks(tick: int24) -> (uint128, uint128, uint256, uint256, uint56, uint160, uint32, bool): view

@external
@view
def get_liquidity_from_pool(pool_address: address) -> (uint128):
    liq0: uint128 = 0
    liq0 = IUniswapV3Pool(pool_address).liquidity()
    return liq0

@external
@view
def get_tokens_in_pool(pool_address:address) -> (address, address):
    return IUniswapV3Pool(pool_address).token0(), IUniswapV3Pool(pool_address).token1()

@external
@view
def get_reserves_by_pools(pool_addresses: DynArray[address,1111]) -> (DynArray[uint128, 1111],DynArray[uint160, 1111],DynArray[int24, 1111]):
    liqs: DynArray[uint128, 1111] = []
    sqrts: DynArray[uint160, 1111] = []
    ticks: DynArray[int24, 1111] = []

    liq: uint128 = 0
    sqrtprice: uint160 = 0
    tick: int24 = 0
    obsindex: uint16 = 0
    obscard: uint16 = 0
    obscardnext: uint16 = 0
    feeprotocol: uint8 = 0
    unlocked: bool = False

    dalen: uint256 = 0
    dalen = len(pool_addresses)
    for i in range(1111):
        if i < dalen:
            liq = IUniswapV3Pool(pool_addresses[i]).liquidity()
            sqrtprice, tick, obsindex, obscard, obscardnext, feeprotocol, unlocked = IUniswapV3Pool(pool_addresses[i]).slot0()
            liqs.append(liq)
            sqrts.append(sqrtprice)
            ticks.append(tick)
        else:
            break
    return liqs, sqrts, ticks