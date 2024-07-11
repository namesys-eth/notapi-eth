// SPDX-License-Identifier: WTFPL.ETH
pragma solidity >0.8.0 <0.9.0;

import "./Interface.sol";
import "./Utils.sol";
import "./CIDv1.sol";

library Generator {
    using Utils for *;
    using CIDv1 for string;

    function toError(string memory _err, bytes memory _data) internal view returns (bytes memory) {
        return string.concat(
            '{"ok":false,"time":',
            (block.timestamp).uintToString(),
            ',"block":',
            block.number.uintToString(),
            ',"error":"',
            _err,
            '","data":"',
            _data.bytesToHexString(),
            '"}'
        ).JSONCIDv1();
    }

    function toError(string memory _err) internal view returns (bytes memory) {
        return string.concat(
            '{"ok":false,"time":',
            (block.timestamp).uintToString(),
            ',"block":',
            block.number.uintToString(),
            ',"error":"',
            _err,
            '","data":""}'
        ).JSONCIDv1();
    }

    function toJSON(string memory _json) internal view returns (bytes memory) {
        return string.concat(
            '{"ok":true,"time":',
            (block.timestamp).uintToString(),
            ',"block":',
            (block.number).uintToString(),
            ",",
            _json,
            "}"
        ).JSONCIDv1();
    }

    function ensDomainData(address _owner, bytes memory _label) internal pure returns (string memory) {
        if (_owner == address(0)) {
            return string.concat('"domain":""');
        }
        return string.concat('"domain":"', string(_label), '.eth"');
    }

    function isAddr(bytes memory _addr) internal pure returns (bool) {
        return (_addr.length == 42 && _addr[0] == bytes1("0") && _addr[1] == bytes1("x"));
    }

    function interfaceCheck(address _contract, bytes4 _interface) internal view returns (bool) {
        try iERC165(_contract).supportsInterface(_interface) returns (bool ok) {
            return ok;
        } catch {
            return false;
        }
        /**
         *  catch Error(string memory) {
         *         return false;
         *     } catch Panic(uint256) {
         *         return false;
         *     } catch (bytes memory) {
         *         return false;
         *     }
         */
    }

    function erc20Balance(address _addr, address _contract) internal view returns (string memory) {
        iERC20 _erc20 = iERC20(_contract);
        return string.concat(
            '"erc":20,"balance":"',
            (_erc20.balanceOf(_addr)).uintToString(),
            '","address":"',
            address(_erc20).toChecksumAddress(),
            '","supply":"',
            (_erc20.totalSupply()).uintToString(),
            '","decimal":',
            (_erc20.decimals()).uintToString(),
            ',"symbol":"',
            _erc20.symbol(),
            '"'
        );
    }

    function erc20Data(address _contract) internal view returns (string memory) {
        iERC20 _erc20 = iERC20(_contract);
        return string.concat(
            '"erc":20,"name":"',
            _erc20.name(),
            '","symbol":"',
            _erc20.symbol(),
            '","decimals":',
            (_erc20.decimals()).uintToString(),
            ',"supply":"',
            (_erc20.totalSupply()).uintToString(),
            '","contract":"',
            _contract.toChecksumAddress(),
            '"'
        );
    }

    function erc721Byid(uint256 _id, address _nft) internal view returns (string memory) {
        iERC721 _erc721 = iERC721(_nft);
        address _owner = _erc721.ownerOf(_id);
        return string.concat(
            '"id":"',
            _id.uintToString(),
            '","owner":"',
            _owner.toChecksumAddress(),
            '","balance":"',
            (_erc721.balanceOf(_owner)).uintToString(),
            '","metadata":"', // @TODO: check & fix metadata/json
            _erc721.tokenURI(_id),
            '"'
        );
    }

    function royalty(uint256 _id, address _contract) internal view returns (string memory) {
        iERC721 _erc721 = iERC721(_contract);
        address _owner = _erc721.ownerOf(_id);
        return string.concat(
            '"erc":721, "balance":"',
            (_erc721.balanceOf(_owner)).uintToString(),
            '","owner":"',
            _owner.toChecksumAddress(),
            '","symbol":"',
            _erc721.symbol(),
            '"'
        );
    }

    function erc721Info(address _nft) internal view returns (string memory) {
        iERC721 _erc721 = iERC721(_nft);
        return string.concat(
            '"erc":721,"supply":"',
            (_erc721.totalSupply()).uintToString(),
            '","contract":"',
            _nft.toChecksumAddress(),
            '","name":"',
            _erc721.name(),
            '","symbol":"',
            _erc721.symbol(),
            '"'
        );
    }

    function checkDecimals20(address _addr) internal view returns (uint8) {
        try iERC20(_addr).decimals() returns (uint8 _decimals) {
            return _decimals;
        } catch {
            return 0;
        }
    }

    function checkBalance(address _addr, address _contract) internal view returns (uint256) {
        try iERC20(_contract).balanceOf(_addr) returns (uint256 _bal) {
            return _bal;
        } catch {
            return 0;
        }
    }

    function supply721(address _addr) internal view returns (string memory) {
        try iERC721(_addr).totalSupply() returns (uint256 _supply) {
            return string.concat('"supply":"', _supply.uintToString(), '"');
        } catch {
            return '"supply":"N/A"';
        }
    }

    function idCheck721(uint256 id, address _addr) internal view returns (address) {
        try iERC721(_addr).ownerOf(id) returns (address _owner) {
            return _owner;
        } catch {
            return address(0);
        }
    }

    function supply1155(address _addr, uint256 _id) internal view returns (string memory) {
        try iERC1155(_addr).totalSupply(_id) returns (uint256 _supply) {
            return string.concat('"supply":"', _supply.uintToString(), '"');
        } catch {
            return '"supply":"N/A"';
        }
    }

    function getCalldata(address _addr, bytes memory _label) public view returns (bool ok, bytes memory _res) {
        (ok, _res) = _addr.staticcall(_label.hexStringToBytes());
        if (ok) {
            if (
                _res.length > 0 && keccak256(abi.encodePacked(bytes32(_res))) != keccak256(abi.encodePacked(bytes32(0)))
            ) {
                _res = bytes(string.concat('"data":"', _res.bytesToHexString(), '"'));
            } else {
                ok = false;
            }
        }
    }
}
