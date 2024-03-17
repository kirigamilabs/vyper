# @version >=0.3.9
from vyper.interfaces import ERC20

owner: address

interface IUniswapV3Pool:
    def token0() -> address: view
    def token1() -> address: view

interface IWETH:
    def balanceOf(addr: address) -> uint256: view
    def transfer(dst: address, wad: uint256): nonpayable
    def withdraw(wad: uint256): nonpayable

@external
def __init__():
    assert msg.sender != empty(address), "owner == ZERO ADDRESS"
    self.owner = msg.sender

@external
def setup():
    assert self.owner == empty(address), "owner != ZERO ADDRESS"
    self.owner = msg.sender

@external
def update(addr: address):
    assert self.owner == msg.sender,"!owner"
    self.owner = addr

#///////////////////////////////////////////////////////////////
#                       SAFE FUNCTIONS
#///////////////////////////////////////////////////////////////

@internal
def _safeTransfer(coin: address, to: address, amount: uint256):
    call_data: Bytes[68] = _abi_encode(to, amount,  method_id=method_id("transfer(address,uint256)"))
    res: Bytes[32] = raw_call(
        coin,
        call_data,
        max_outsize=32,
    )
    if len(res) > 0:
        assert convert(res, bool)

@internal
def _safeApprove(coin: address, to: address, amount: uint256):
    call_data: Bytes[68] = _abi_encode(to, amount,  method_id=method_id("approve(address,uint256)"))
    res: Bytes[32] = raw_call(
        coin,
        call_data,
        max_outsize=32,
    )
    if len(res) > 0:
        assert convert(res, bool)

#///////////////////////////////////////////////////////////////
#                       SWAP FUNCTIONS
#///////////////////////////////////////////////////////////////

@internal
def _v22swap(pool_address: address, amountOut: uint256, zeroForOne: bool, recipient: address):
    amountOut0: uint256 = 0
    amountOut1: uint256 = 0
    if zeroForOne:
        amountOut1 = amountOut
    else:
        amountOut0 = amountOut
    raw_call(
        pool_address,
        concat(
            method_id("swap(uint256,uint256,address,bytes)"),
            convert(amountOut0, bytes32),
            convert(amountOut1, bytes32),
            convert(recipient, bytes32),
            convert(128, bytes32),
            convert(0, bytes32)
        ),
        max_outsize=0,
    )

@internal
def _v23swap(pool_address: address, amountSpecified: int256, zeroForOne: bool, theData: Bytes[1024], recipient: address):
    sqrtPriceLimitX96: uint160 = 1461446703485210103287273052203988822378723970341
    if zeroForOne:
        sqrtPriceLimitX96 = 4295128740
    res: Bytes[128] = raw_call(
        pool_address,
        concat(
            method_id("swap(address,bool,int256,uint160,bytes)"),
            convert(recipient, bytes32),
            convert(zeroForOne, bytes32),
            convert(amountSpecified, bytes32),
            convert(sqrtPriceLimitX96, bytes32),
            convert(160, bytes32),
            convert(len(theData), bytes32),
            theData
        ),
        max_outsize=128,
    )

#///////////////////////////////////////////////////////////////
#                 UNISWAP V3 SWAP CALLBACK
#///////////////////////////////////////////////////////////////

@external
def uniswapV3SwapCallback(_amount0d: int256, _amount1d: int256, _data: Bytes[448]):
    if _amount0d < 0:
        if len(_data) == 224:
            if convert(slice(_data, 0, 32), uint8) == 3:
                if convert(slice(_data, 160, 32), bool):
                    self._v23swap(convert(slice(_data, 32, 32), address), 0-convert(slice(_data, 64, 32), int256), convert(slice(_data, 96, 32), bool), empty(Bytes[1024]), convert(slice(_data, 192, 32), address))
                else:
                    self._v23swap(convert(slice(_data, 32, 32), address), convert(slice(_data, 128, 32), int256), convert(slice(_data, 96, 32), bool), empty(Bytes[1024]), convert(slice(_data, 192, 32), address))
            else:
                if convert(slice(_data, 192, 32), address) == msg.sender: 
                    self._safeTransfer(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, convert(slice(_data, 32, 32), address), convert(slice(_data, 128, 32), uint256))
                    self._v22swap(convert(slice(_data, 32, 32), address), convert(slice(_data, 64, 32), uint256), convert(slice(_data, 96, 32), bool), convert(slice(_data, 192, 32), address))
                else:
                    self._v22swap(convert(slice(_data, 32, 32), address), convert(slice(_data, 64, 32), uint256), convert(slice(_data, 96, 32), bool), convert(slice(_data, 192, 32), address))
                    self._safeTransfer(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, msg.sender, convert(_amount1d, uint256))      
        elif len(_data) == 448:
            if convert(slice(_data, 224, 32), uint8) == 3:
                if convert(slice(_data, 384, 32), bool):
                    self._v23swap(convert(slice(_data, 256, 32), address), 0-convert(slice(_data, 288, 32), int256), convert(slice(_data, 320, 32), bool), slice(_data, 0, 224), convert(slice(_data, 416, 32), address))
                else:
                    self._v23swap(convert(slice(_data, 256, 32), address), convert(slice(_data, 352, 32), int256), convert(slice(_data, 320, 32), bool), slice(_data, 0, 224), convert(slice(_data, 416, 32), address))
            elif convert(slice(_data, 0, 32), uint8) == 3:
                if convert(slice(_data, 160, 32), bool):
                    self._v23swap(convert(slice(_data, 32, 32), address), 0-convert(slice(_data, 64, 32), int256), convert(slice(_data, 96, 32), bool), slice(_data, 224, 224), convert(slice(_data, 192, 32), address))
                else:
                    self._v23swap(convert(slice(_data, 32, 32), address), convert(slice(_data, 128, 32), int256), convert(slice(_data, 96, 32), bool), slice(_data, 224, 224), convert(slice(_data, 192, 32), address))   
            else:
                if convert(slice(_data, 192, 32), address) == msg.sender: 
                    self._v22swap(convert(slice(_data, 256, 32), address), convert(slice(_data, 288, 32), uint256), convert(slice(_data, 320, 32), bool), convert(slice(_data, 416, 32), address))
                    self._safeTransfer(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, convert(slice(_data, 32, 32), address),convert(slice(_data, 128, 32), uint256))
                    self._v22swap(convert(slice(_data, 32, 32), address), convert(slice(_data, 64, 32), uint256), convert(slice(_data, 96, 32), bool), convert(slice(_data, 192, 32), address)) 
                elif convert(slice(_data, 416, 32), address) == msg.sender:
                    self._safeTransfer(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, convert(slice(_data, 32, 32), address),convert(slice(_data, 128, 32), uint256))
                    self._v22swap(convert(slice(_data, 32, 32), address), convert(slice(_data, 64, 32), uint256), convert(slice(_data, 96, 32), bool), convert(slice(_data, 192, 32), address)) 
                    self._v22swap(convert(slice(_data, 256, 32), address), convert(slice(_data, 288, 32), uint256), convert(slice(_data, 320, 32), bool), convert(slice(_data, 416, 32), address))
                elif convert(slice(_data, 416, 32), address) == self:
                    self._v22swap(convert(slice(_data, 32, 32), address), convert(slice(_data, 64, 32), uint256), convert(slice(_data, 96, 32), bool), convert(slice(_data, 192, 32), address)) 
                    self._v22swap(convert(slice(_data, 256, 32), address), convert(slice(_data, 288, 32), uint256), convert(slice(_data, 320, 32), bool), convert(slice(_data, 416, 32), address))
                    self._safeTransfer(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, msg.sender, convert(_amount1d, uint256))
                else:
                    assert False, "V23InvalidData0"
        elif len(_data) == 0:       
            self._safeTransfer(IUniswapV3Pool(msg.sender).token1(), msg.sender, convert(_amount1d, uint256))
        else:       
            assert False, "V3InvalidData0"
    elif _amount1d < 0:
        if len(_data) == 224:
            if convert(slice(_data, 0, 32), uint8) == 3:
                if convert(slice(_data, 160, 32), bool):
                    self._v23swap(convert(slice(_data, 32, 32), address), 0-convert(slice(_data, 64, 32), int256), convert(slice(_data, 96, 32), bool), empty(Bytes[1024]), convert(slice(_data, 192, 32), address))
                else:
                    self._v23swap(convert(slice(_data, 32, 32), address), convert(slice(_data, 128, 32), int256), convert(slice(_data, 96, 32), bool), empty(Bytes[1024]), convert(slice(_data, 192, 32), address))
            else:
                if convert(slice(_data, 192, 32), address) == msg.sender: 
                    self._safeTransfer(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, convert(slice(_data, 32, 32), address), convert(slice(_data, 128, 32), uint256))
                    self._v22swap(convert(slice(_data, 32, 32), address), convert(slice(_data, 64, 32), uint256), convert(slice(_data, 96, 32), bool), convert(slice(_data, 192, 32), address))
                else:
                    self._v22swap(convert(slice(_data, 32, 32), address), convert(slice(_data, 64, 32), uint256), convert(slice(_data, 96, 32), bool), convert(slice(_data, 192, 32), address))
                    self._safeTransfer(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, msg.sender, convert(_amount0d, uint256))
        elif len(_data) == 448:
            if convert(slice(_data, 224, 32), uint8) == 3:
                if convert(slice(_data, 384, 32), bool):
                    self._v23swap(convert(slice(_data, 256, 32), address), 0-convert(slice(_data, 288, 32), int256), convert(slice(_data, 320, 32), bool), slice(_data, 0, 224), convert(slice(_data, 416, 32), address))
                else:
                    self._v23swap(convert(slice(_data, 256, 32), address), convert(slice(_data, 352, 32), int256), convert(slice(_data, 320, 32), bool), slice(_data, 0, 224), convert(slice(_data, 416, 32), address))  
            elif convert(slice(_data, 0, 32), uint8) == 3:
                if convert(slice(_data, 160, 32), bool):
                    self._v23swap(convert(slice(_data, 32, 32), address), 0-convert(slice(_data, 64, 32), int256), convert(slice(_data, 96, 32), bool), slice(_data, 224, 224), convert(slice(_data, 192, 32), address))
                else:
                    self._v23swap(convert(slice(_data, 32, 32), address), convert(slice(_data, 128, 32), int256), convert(slice(_data, 96, 32), bool), slice(_data, 224, 224), convert(slice(_data, 192, 32), address))
            else:
                if convert(slice(_data, 192, 32), address) == msg.sender: 
                    self._v22swap(convert(slice(_data, 256, 32), address), convert(slice(_data, 288, 32), uint256), convert(slice(_data, 320, 32), bool), convert(slice(_data, 416, 32), address))
                    self._safeTransfer(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, convert(slice(_data, 32, 32), address),convert(slice(_data, 128, 32), uint256))
                    self._v22swap(convert(slice(_data, 32, 32), address), convert(slice(_data, 64, 32), uint256), convert(slice(_data, 96, 32), bool), convert(slice(_data, 192, 32), address)) 
                elif convert(slice(_data, 416, 32), address) == msg.sender:
                    self._safeTransfer(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, convert(slice(_data, 32, 32), address),convert(slice(_data, 128, 32), uint256))
                    self._v22swap(convert(slice(_data, 32, 32), address), convert(slice(_data, 64, 32), uint256), convert(slice(_data, 96, 32), bool), convert(slice(_data, 192, 32), address)) 
                    self._v22swap(convert(slice(_data, 256, 32), address), convert(slice(_data, 288, 32), uint256), convert(slice(_data, 320, 32), bool), convert(slice(_data, 416, 32), address))
                elif convert(slice(_data, 416, 32), address) == self:
                    self._v22swap(convert(slice(_data, 32, 32), address), convert(slice(_data, 64, 32), uint256), convert(slice(_data, 96, 32), bool), convert(slice(_data, 192, 32), address)) 
                    self._v22swap(convert(slice(_data, 256, 32), address), convert(slice(_data, 288, 32), uint256), convert(slice(_data, 320, 32), bool), convert(slice(_data, 416, 32), address))
                    self._safeTransfer(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, msg.sender, convert(_amount0d, uint256))
                else:
                    assert False, "V23InvalidData1"
        elif len(_data) == 0:       
            self._safeTransfer(IUniswapV3Pool(msg.sender).token0(), msg.sender, convert(_amount0d, uint256))
        else:
            assert False, "V3InvalidData1"  
    else:
        assert False, "V3InvalidSwap3"

#///////////////////////////////////////////////////////////////
#                       RPO23
#///////////////////////////////////////////////////////////////

@external
def rpo2(flash: uint8, amountIn: uint256, dex: uint8[2], pool_address: address[2], amountOut: uint256[2], zeroForOne: bool[2]):
    assert self.owner == msg.sender,"!owner"
    if dex[1] == 3:
        thedata: Bytes[224] = concat(
            convert(dex[0], bytes32),
            convert(pool_address[0], bytes32),
            convert(amountOut[0], bytes32),
            convert(zeroForOne[0], bytes32),
            convert(amountIn, bytes32),
            convert(False, bytes32),
            convert(pool_address[1], bytes32)
        )
        self._v23swap(pool_address[1], 0-convert(amountOut[1], int256), zeroForOne[1], thedata, self)
    elif dex[0] == 3:
        thedata: Bytes[224] = concat(
            convert(dex[1], bytes32),
            convert(pool_address[1], bytes32),
            convert(amountOut[1], bytes32),
            convert(zeroForOne[1], bytes32),
            convert(amountOut[0], bytes32),
            convert(True, bytes32),
            convert(self, bytes32)
        )
        self._v23swap(pool_address[0], convert(amountIn, int256), zeroForOne[0], thedata, pool_address[1])
    else:
        if flash == 1:
            thedata: Bytes[192] = concat(
                convert(pool_address[0], bytes32),
                convert(amountOut[0], bytes32),
                convert(zeroForOne[0], bytes32),
                convert(pool_address[1], bytes32),
                convert(amountOut[1], bytes32),
                convert(zeroForOne[1], bytes32)
            )
            self._flash(amountIn, thedata)
        else:
            self._safeTransfer(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, pool_address[0], amountIn)
            self._v22swap(pool_address[0], amountOut[0], zeroForOne[0], pool_address[1])
            self._v22swap(pool_address[1], amountOut[1], zeroForOne[1], self)
    #self._safeTransfer(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, msg.sender, IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2).balanceOf(self))
    IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2).withdraw(IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2).balanceOf(self))
    send(self.owner, self.balance)

@external
def rpo3(flash: uint8, amountIn: uint256, dex: uint8[3], pool_address: address[3], amountOut: uint256[3], zeroForOne: bool[3]):
    assert self.owner == msg.sender,"!owner"
    if dex[2] == 3:
        thedata: Bytes[448] = concat(
            convert(dex[0], bytes32),
            convert(pool_address[0], bytes32),
            convert(amountOut[0], bytes32),
            convert(zeroForOne[0], bytes32),
            convert(amountIn, bytes32),
            convert(False, bytes32),
            convert(pool_address[1], bytes32),
            convert(dex[1], bytes32),
            convert(pool_address[1], bytes32),
            convert(amountOut[1], bytes32),
            convert(zeroForOne[1], bytes32),
            convert(amountOut[0], bytes32),
            convert(True, bytes32),
            convert(pool_address[2], bytes32)
        )
        self._v23swap(pool_address[2], 0-convert(amountOut[2], int256), zeroForOne[2], thedata, self)
    elif dex[1] == 3:
        thedata: Bytes[448] = concat(
            convert(dex[0], bytes32),
            convert(pool_address[0], bytes32),
            convert(amountOut[0], bytes32),
            convert(zeroForOne[0], bytes32),
            convert(amountIn, bytes32),
            convert(False, bytes32),
            convert(pool_address[1], bytes32),
            convert(dex[2], bytes32),
            convert(pool_address[2], bytes32),
            convert(amountOut[2], bytes32),
            convert(zeroForOne[2], bytes32),
            convert(amountOut[1], bytes32),
            convert(True, bytes32),
            convert(self, bytes32)
        )
        self._v23swap(pool_address[1], 0-convert(amountOut[1], int256), zeroForOne[1], thedata, pool_address[2])
    elif dex[0] == 3:
        thedata: Bytes[448] = concat(
            convert(dex[1], bytes32),
            convert(pool_address[1], bytes32),
            convert(amountOut[1], bytes32),
            convert(zeroForOne[1], bytes32),
            convert(amountOut[0], bytes32),
            convert(True, bytes32),
            convert(pool_address[2], bytes32),
            convert(dex[2], bytes32),
            convert(pool_address[2], bytes32),
            convert(amountOut[2], bytes32),
            convert(zeroForOne[2], bytes32),
            convert(amountOut[1], bytes32),
            convert(True, bytes32),
            convert(self, bytes32)
        )
        self._v23swap(pool_address[0], convert(amountIn, int256), zeroForOne[0], thedata, pool_address[1])
    else:
        if flash == 1:
            thedata: Bytes[288] = concat(
                convert(pool_address[0], bytes32),
                convert(amountOut[0], bytes32),
                convert(zeroForOne[0], bytes32),
                convert(pool_address[1], bytes32),
                convert(amountOut[1], bytes32),
                convert(zeroForOne[1], bytes32),
                convert(pool_address[2], bytes32),
                convert(amountOut[2], bytes32),
                convert(zeroForOne[2], bytes32)
            )
            self._flash(amountIn, thedata)
        else:
            self._safeTransfer(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, pool_address[0], amountIn)
            self._v22swap(pool_address[0], amountOut[0], zeroForOne[0], pool_address[1])
            self._v22swap(pool_address[1], amountOut[1], zeroForOne[1], pool_address[2])
            self._v22swap(pool_address[2], amountOut[2], zeroForOne[2], self)
    #self._safeTransfer(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, msg.sender, IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2).balanceOf(self))
    IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2).withdraw(IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2).balanceOf(self))
    send(self.owner, self.balance)

#///////////////////////////////////////////////////////////////
#                 FLASH FUNCTIONS
#///////////////////////////////////////////////////////////////

@internal
def _flash(amountIn: uint256, thedata: Bytes[1024]):
    raw_call(
        0xBA12222222228d8Ba445958a75a0704d566BF2C8,
        concat(
            method_id("flashLoan(address,address[],uint256[],bytes)"),
            convert(self, bytes32),
            convert(128, bytes32), # address[] offset
            convert(192, bytes32), # amounts[] offset
            convert(256, bytes32), # bytes offset
            convert(1, bytes32),  # address[] length
            convert(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, bytes32), # address[0]
            convert(1, bytes32),  # amounts[] length
            convert(amountIn, bytes32), # amounts[0]
            convert(len(thedata), bytes32),  # bytes length
            thedata #bytes
        ),
        max_outsize=0,
    )

#///////////////////////////////////////////////////////////////
#               RECEIVE BALANCER V2 FLASH
#///////////////////////////////////////////////////////////////

@external
def receiveFlashLoan(_tokens: DynArray[address,3], _amounts: DynArray[uint256,3], _feeAmounts: DynArray[uint256,3], _userData: Bytes[288]): 
    assert msg.sender == 0xBA12222222228d8Ba445958a75a0704d566BF2C8, "!VAULT"
    if _feeAmounts[0] == 0:
        if len(_userData) == 288:
            self._safeTransfer(_tokens[0], convert(slice(_userData, 0, 32), address), _amounts[0])
            self._v22swap(convert(slice(_userData, 0, 32), address), convert(slice(_userData, 32, 32), uint256), convert(slice(_userData, 64, 32), bool), convert(slice(_userData, 96, 32), address))
            self._v22swap(convert(slice(_userData, 96, 32), address), convert(slice(_userData, 128, 32), uint256), convert(slice(_userData, 160, 32), bool), convert(slice(_userData, 192, 32), address))
            self._v22swap(convert(slice(_userData, 192, 32), address), convert(slice(_userData, 224, 32), uint256), convert(slice(_userData, 256, 32), bool), self)
            self._safeTransfer(_tokens[0], msg.sender, _amounts[0])
        elif len(_userData) == 192:
            self._safeTransfer(_tokens[0], convert(slice(_userData, 0, 32), address), _amounts[0])
            self._v22swap(convert(slice(_userData, 0, 32), address), convert(slice(_userData, 32, 32), uint256), convert(slice(_userData, 64, 32), bool), convert(slice(_userData, 96, 32), address))
            self._v22swap(convert(slice(_userData, 96, 32), address), convert(slice(_userData, 128, 32), uint256), convert(slice(_userData, 160, 32), bool), self)
            self._safeTransfer(_tokens[0], msg.sender, _amounts[0]) 
        else:
            assert False, "BalancerInvalidData"    
    else:
        assert False, "BalancerInvalidFlash"


#///////////////////////////////////////////////////////////////
#                    FETCH FUNCTIONS
#///////////////////////////////////////////////////////////////

@external
def fetchTokens(_token: address, _amount: uint256, _to: address):
    assert self.owner == msg.sender,"!owner"
    sent: bool = ERC20(_token).transfer(_to, _amount)
    assert sent, "!TRANSFER"

@external
def fetchETH(_amount: uint256, _to: address):
    assert self.owner == msg.sender,"!owner"
    send(_to, _amount)

@external
@payable
def __default__():
    pass