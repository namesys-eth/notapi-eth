// SPDX-License-Identifier: WTFPL.ETH
pragma solidity >0.8.0 <0.9.0;

import "./Interface.sol";
import "./Utils.sol";

library ERC20Data {
    using Utils for *;

    function checkSupply(iERC20 erc20) internal view returns (uint256) {
        try erc20.totalSupply{gas: 99999}() returns (uint256 _supply) {
            return _supply;
        } catch {
            return 0;
        }
    }

    function getInfo(iERC20 erc20) internal view returns (bytes memory) {
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

    function getBalance(iERC20 erc20, address _addr) internal view returns (bytes memory) {
        return string.concat(
            '{"symbol":"',
            erc20.symbol(),
            '","balance":"',
            (erc20.balanceOf(_addr)).uintToString(),
            '","totalsupply":"',
            (erc20.totalSupply()).uintToString(),
            '","decimal":"',
            (erc20.decimals()).uintToString(),
            '","address":"',
            (_addr).toChecksumAddress(),
            '","timestamp":"',
            (block.timestamp).uintToString(),
            '"}'
        ).toJSON();
        //uint256 _unit = _dec == 0 ? 1 : 10 ** _dec;
        //'","bal":"',
        //(_bal / _unit).uintToString(),
        //".",
        //(_bal % _unit).uintToString(),
    }

    function getAllowance(iERC20 erc20, address _owner, address _spender) internal view returns (bytes memory) {
        return string.concat(
            '{"symbol":"',
            erc20.symbol(),
            '","allowance":"',
            (erc20.allowance(_owner, _spender)).uintToString(),
            '","balance":"',
            (erc20.balanceOf(_owner)).uintToString(),
            '","decimal":"',
            (erc20.decimals()).uintToString(),
            '","timestamp":"',
            (block.timestamp).uintToString(),
            '"}'
        ).toJSON();
        //'","owner":"',
        //(_owner).toChecksumAddress(),
        //'","spender":"',
        //(_spender).toChecksumAddress(),
    }
}
