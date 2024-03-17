# @version >=0.3.9

interface IERC20:
    def name() -> String[512]: view
    def symbol() -> String[64]: view
    def totalSupply() -> uint256: view
    def decimals() -> uint8: view
    def balanceOf(addr: address) -> uint256: view
    def allowance(owner: address, spender: address) -> uint256: view
    
interface IUniswapV2Factory:
    def getPair(tokenA: address, tokenB: address) -> address: view

interface IUniswapV2Pair:
    def token0() -> address: view
    def token1() -> address: view
    def getReserves() -> (uint256, uint256, uint256): view

interface IUniswapV3Factory:
    def getPool(tokenA: address, tokenB: address, fee: uint24) -> address: view

interface IUniswapV3Pool:
    def token0() -> address: view
    def token1() -> address: view
    def liquidity() -> uint128: view
    def slot0() -> (uint160, int24, uint16, uint16, uint16, uint8, bool): view
    def ticks(tick: int24) -> (uint128, uint128, uint256, uint256, uint56, uint160, uint32, bool): view

@external
@view
def get_v3data(factory_address: address, token0_addresses: DynArray[address,1111],token1_addresses: DynArray[address,1111], fees0: DynArray[uint24,1111]) -> (DynArray[address, 1111], DynArray[uint128, 1111],DynArray[uint160, 1111],DynArray[int24, 1111], DynArray[address,1111], DynArray[String[512], 1111],DynArray[String[64], 1111],DynArray[uint8, 1111], DynArray[address,1111], DynArray[String[512], 1111],DynArray[String[64], 1111],DynArray[uint8, 1111]):
    dalen: uint256 = 0
    dalen = len(token0_addresses)
    assert dalen == len(token1_addresses), "token lengths must be the same!"
    assert dalen == len(fees0), "token and fees must be the same length!"

    pool_addresses: DynArray[address, 1111] = []
    token0_ids: DynArray[address, 1111] = []
    token0_names: DynArray[String[512], 1111] = []
    token0_symbols: DynArray[String[64], 1111] = []
    token0_decimals: DynArray[uint8, 1111] = []
    token1_ids: DynArray[address, 1111] = []
    token1_names: DynArray[String[512], 1111] = []
    token1_symbols: DynArray[String[64], 1111] = []
    token1_decimals: DynArray[uint8, 1111] = []

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
    tickspacing: int24 = 0
    tickrange: int24 = 0
    bottomtick: int24 = 0
    uppertick: int24 = 0
    bbtick: int24 = 0
    uutick: int24 = 0
    bbbtick: int24 = 0
    uuutick: int24 = 0

    for i in range(1111):
        if i < dalen:
            pool_addresses.append(IUniswapV3Factory(factory_address).getPool(token0_addresses[i], token1_addresses[i], fees0[i]))

            liq = IUniswapV3Pool(pool_addresses[i]).liquidity()
            sqrtprice, tick, obsindex, obscard, obscardnext, feeprotocol, unlocked = IUniswapV3Pool(pool_addresses[i]).slot0()
            liqs.append(liq)
            sqrts.append(sqrtprice)
            ticks.append(tick)

            if fees0[i] == 10000: tickspacing = 200
            elif fees0[i] == 3000: tickspacing = 60
            elif fees0[i] == 500: tickspacing = 10
            elif fees0[i] == 100: tickspacing = 1
            else: tickspacing = 0
            tickrange = tick/tickspacing
            bottomtick = tickrange*tickspacing
            uppertick = bottomtick+tickspacing
            bbtick = bottomtick-tickspacing
            uutick = uppertick+tickspacing
            bbbtick = bbtick-tickspacing
            uuutick = uutick+tickspacing


            if token0_addresses[i] == IUniswapV3Pool(pool_addresses[i]).token0():
                token0_ids.append(token0_addresses[i])
                token0_names.append(IERC20(token0_addresses[i]).name())
                token0_symbols.append(IERC20(token0_addresses[i]).symbol())
                token0_decimals.append(IERC20(token0_addresses[i]).decimals())
                token1_ids.append(token1_addresses[i])
                token1_names.append(IERC20(token1_addresses[i]).name())
                token1_symbols.append(IERC20(token1_addresses[i]).symbol())
                token1_decimals.append(IERC20(token1_addresses[i]).decimals())
            else:
                token0_ids.append(token1_addresses[i])
                token0_names.append(IERC20(token1_addresses[i]).name())
                token0_symbols.append(IERC20(token1_addresses[i]).symbol())
                token0_decimals.append(IERC20(token1_addresses[i]).decimals())
                token1_ids.append(token0_addresses[i])
                token1_names.append(IERC20(token0_addresses[i]).name())
                token1_symbols.append(IERC20(token0_addresses[i]).symbol())
                token1_decimals.append(IERC20(token0_addresses[i]).decimals())
        else:
            break

    return pool_addresses, liqs, sqrts, ticks, token0_ids, token0_names, token0_symbols, token0_decimals, token1_ids, token1_names, token1_symbols, token1_decimals

@external
@view
def get_v2data(factory_address: address, token0_addresses: DynArray[address,1111],token1_addresses: DynArray[address,1111]) -> (DynArray[address, 1111],DynArray[uint256[3], 1111], DynArray[address,1111], DynArray[String[512], 1111],DynArray[String[64], 1111],DynArray[uint8, 1111], DynArray[address,1111], DynArray[String[512], 1111],DynArray[String[64], 1111],DynArray[uint8, 1111]):
    dalen: uint256 = 0
    dalen = len(token0_addresses)
    assert dalen == len(token1_addresses), "token lengths must be the same!"

    pair_addresses: DynArray[address, 1111] = []
    token0_ids: DynArray[address, 1111] = []
    token0_names: DynArray[String[512], 1111] = []
    token0_symbols: DynArray[String[64], 1111] = []
    token0_decimals: DynArray[uint8, 1111] = []
    token1_ids: DynArray[address, 1111] = []
    token1_names: DynArray[String[512], 1111] = []
    token1_symbols: DynArray[String[64], 1111] = []
    token1_decimals: DynArray[uint8, 1111] = []

    result: DynArray[uint256[3], 1111] = []
    rr: uint256[3] = empty(uint256[3])

    for i in range(1111):
        if i < dalen:
            pair_addresses.append(IUniswapV2Factory(factory_address).getPair(token0_addresses[i], token1_addresses[i]))
            
            rr[0],rr[1],rr[2] = IUniswapV2Pair(pair_addresses[i]).getReserves()
            result.append(rr)

            if token0_addresses[i] == IUniswapV2Pair(pair_addresses[i]).token0():
                token0_ids.append(token0_addresses[i])
                token0_names.append(IERC20(token0_addresses[i]).name())
                token0_symbols.append(IERC20(token0_addresses[i]).symbol())
                token0_decimals.append(IERC20(token0_addresses[i]).decimals())
                token1_ids.append(token1_addresses[i])
                token1_names.append(IERC20(token1_addresses[i]).name())
                token1_symbols.append(IERC20(token1_addresses[i]).symbol())
                token1_decimals.append(IERC20(token1_addresses[i]).decimals())
            else:
                token0_ids.append(token1_addresses[i])
                token0_names.append(IERC20(token1_addresses[i]).name())
                token0_symbols.append(IERC20(token1_addresses[i]).symbol())
                token0_decimals.append(IERC20(token1_addresses[i]).decimals())
                token1_ids.append(token0_addresses[i])
                token1_names.append(IERC20(token0_addresses[i]).name())
                token1_symbols.append(IERC20(token0_addresses[i]).symbol())
                token1_decimals.append(IERC20(token0_addresses[i]).decimals())
        else:
            break

    return pair_addresses, result, token0_ids, token0_names, token0_symbols, token0_decimals, token1_ids, token1_names, token1_symbols, token1_decimals

@external
@view
def get_tokendata(token_address:address) -> (String[512], String[64], uint8):
    return IERC20(token_address).name(), IERC20(token_address).symbol(), IERC20(token_address).decimals()

@external
@view
def get_tokenname(token_address:address) -> (String[512]):
    return IERC20(token_address).name()

@external
@view
def get_tokensymbol(token_address:address) -> (String[64]):
    return IERC20(token_address).symbol()

@external
@view
def get_tokendecimal(token_address:address) -> (uint8):
    return IERC20(token_address).decimals()


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
def get_tokens_in_pair(pool_address:address) -> (address, address):
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


@external
@view
def get_pool_from_factory(
    factory_address: address, 
    tokenA: address, 
    tokenB: address,
    fee0: uint24
) -> address:
    assert tokenA != tokenB, "token addresses must be different!"
    return IUniswapV3Factory(factory_address).getPool(tokenA, tokenB, fee0)

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