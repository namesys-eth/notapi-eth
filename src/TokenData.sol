pragma solidity >0.8.0 <0.9.0;

import "./Interface.sol";
import "./Utils.sol";

library TokenData {
    using Utils for *;

    function checkSupply(iERC20 erc20) internal view returns (uint256) {
        try erc20.totalSupply{gas: 99999}() returns (uint256 _supply) {
            return _supply;
        } catch {
            return 0;
        }
    }

    function info(iERC20 erc20) internal view returns (bytes memory) {
        return string.concat(
            '{"name":"',
            erc20.name(),
            '","contract":"',
            address(erc20).toChecksumAddress(),
            '","symbol":"',
            erc20.symbol(),
            '","totalsupply":"',
            (erc20.totalSupply()).uintToString(),
            '","decimal":"',
            (erc20.decimals()).uintToString(),
            '","timestamp":"',
            (block.timestamp).uintToString(),
            '"}'
        ).toJSON();
        //'","block":"',
        //(block.number).uintToString(),
    }

    function balance(iERC20 erc20, address _addr) internal view returns (bytes memory) {
        uint256 _bal = erc20.balanceOf(_addr);
        uint8 _dec = erc20.decimals();
        uint256 _supply = erc20.totalSupply();
        uint256 _unit = _dec == 0 ? 1 : 10 ** _dec;
        return string.concat(
            '{"symbol":"',
            erc20.symbol(),
            '","balance":"',
            _bal.uintToString(),
            '","bal":"',
            (_bal / _unit).uintToString(),
            ".",
            (_bal % _unit).uintToString(),
            '","totalsupply":"',
            (_supply).uintToString(),
            '","decimal":"',
            (_dec).uintToString(),
            '","address":"',
            (_addr).toChecksumAddress(),
            '","timestamp":"',
            (block.timestamp).uintToString(),
            '"}'
        ).toJSON();
        //'","block":"',
        //(block.number).uintToString(),
    }
    function allowed(iERC20 erc20, address _owner, address _spender) internal view returns (bytes memory) {
        uint256 _approved = erc20.allowance(_owner, _spender);
        uint8 _dec = erc20.decimals();
        uint256 _unit = _dec == 0 ? 1 : 10 ** _dec;
        return string.concat(
            '{"symbol":"',
            erc20.symbol(),
            '","allowance":"',
            _approved.uintToString(),
            '","allow":"',
            (_approved / _unit).uintToString(),
            ".",
            (_approved % _unit).uintToString(),
            '","decimal":"',
            (_dec).uintToString(),
            '","owner":"',
            (_owner).toChecksumAddress(),
            '","spender":"',
            (_spender).toChecksumAddress(),
            '","timestamp":"',
            (block.timestamp).uintToString(),
            '"}'
        ).toJSON();
        //'","block":"',
        //(block.number).uintToString(),
    }
}
