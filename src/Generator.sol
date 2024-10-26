// SPDX-License-Identifier: WTFPL.ETH
pragma solidity >0.8.0 <0.9.0;

/**
 * @title Generator Library
 * @dev A library for generating various data formats and handling ERC20/ERC721 token interactions.
 */
import "./Interface.sol";
import "./LibString.sol"; // Updated to use LibString
import "./CIDv1.sol";

library Generator {
    using CIDv1 for bytes;
    using LibString for *; // Updated to use LibString

    /**
     * @dev Returns an error message in JSON format.
     * @param _err error message.
     * @param _data Additional data related to the error.
     * @return A bytes representation of the error message.
     */
    function toError(string memory _err, bytes memory _data) internal view returns (bytes memory) {
        return abi.encodePacked(
            '{"ok":false,"time":',
            (block.timestamp).toString(),
            ',"block":',
            block.number.toString(),
            ',"error":"',
            _err,
            '","data":"',
            _data.toHexString(),
            '"}'
        ) // Updated to use LibString
                // Updated to use LibString
                // Updated to use LibString
            .toJSONCIDv1();
    }

    /**
     * @dev Returns an error message in JSON format without additional data.
     * @param _err error message.
     * @return A bytes representation of the error message.
     */
    function toError(string memory _err) internal view returns (bytes memory) {
        return abi.encodePacked(
            '{"ok":false,"time":',
            (block.timestamp).toString(),
            ',"block":',
            block.number.toString(),
            ',"error":"',
            _err,
            '","data":""}'
        ) // Updated to use LibString
                // Updated to use LibString
            .toJSONCIDv1();
    }

    /**
     * @dev Returns a JSON representation of the provided data.
     * @param _json JSON string to include in the result.
     * @return A bytes representation of the JSON data.
     */
    function toJSON(bytes memory _json) internal view returns (bytes memory) {
        return abi.encodePacked(
            string('{"ok":true,"time":'),
            (block.timestamp).toString(),
            ',"block":',
            (block.number).toString(),
            ',"result":{',
            _json,
            "}}"
        ) // Updated to use LibString
                // Updated to use LibString
            .toJSONCIDv1();
    }

    /**
     * @dev Generates ENS domain data based on the owner's address and label.
     * @param _owner address of the domain owner.
     * @param _label label for the domain.
     * @return A string representation of the ENS domain data.
     */
    function ensDomainData(address _owner, bytes memory _label) internal pure returns (string memory) {
        if (_owner == address(0)) {
            return string.concat('"domain":""');
        }
        return string.concat('"domain":"', string(_label), '.eth"');
    }

    /**
     * @dev Checks if the provided bytes represent a valid Ethereum address.
     * @param _addr bytes representation of the address.
     * @return True if valid, false otherwise.
     */
    function isAddr(bytes memory _addr) internal pure returns (bool) {
        return (_addr.length == 42 && _addr[1] == bytes1("x") && _addr[0] == bytes1("0"));
    }

    /**
     * @dev Checks if a contract supports a specific interface.
     * @param _contract address of the contract.
     * @param _interface interface identifier.
     * @return True if the interface is supported, false otherwise.
     */
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

    /**
     * @dev Retrieves the balance of an ERC20 token for a given address.
     * @param _addr address to check the balance for.
     * @param _contract address of the ERC20 contract.
     * @return A string representation of the balance.
     */
    function erc20Balance(address _addr, address _contract) internal view returns (string memory) {
        iERC20 _erc20 = iERC20(_contract);
        return string.concat(
            '"erc":20,"balance":"',
            (_erc20.balanceOf(_addr)).toString(), // Updated to use LibString
            '","address":"',
            address(_erc20).toHexStringChecksummed(), // Ensure this is correct
            '","supply":"',
            (_erc20.totalSupply()).toString(), // Updated to use LibString
            '","decimal":',
            (_erc20.decimals()).toString(), // Updated to use LibString
            ',"symbol":"',
            _erc20.symbol(),
            '","contract":"',
            address(_contract).toHexStringChecksummed(), // Ensure this is correct
            '"'
        );
    }

    /**
     * @dev Retrieves information about an ERC20 token.
     * @param _contract address of the ERC20 contract.
     * @return A string representation of the token information.
     */
    function getERC20Info(address _contract) internal view returns (bytes memory) {
        iERC20 _erc20 = iERC20(_contract);
        return abi.encodePacked(
            '"contract":"',
            _contract.toHexStringChecksummed(),
            '","decimals":',
            _erc20.decimals().toString(), // Updated to use LibString
            ',"erc":20,"name":"',
            _erc20.name(),
            '","supply":"',
            _erc20.totalSupply().toString(), // Updated to use LibString
            '","symbol":"',
            _erc20.symbol(),
            '"'
        );
    }

    /**
     * @dev Retrieves information about an ERC721 token by ID.
     * @param _id ID of the token.
     * @param _nft address of the ERC721 contract.
     * @return A string representation of the token information.
     */
    function erc721Byid(uint256 _id, address _nft) internal view returns (string memory) {
        iERC721 _erc721 = iERC721(_nft);
        address _owner = _erc721.ownerOf(_id);
        return string.concat(
            '"id":"',
            _id.toString(), // Updated to use LibString
            '","address":"',
            _owner.toHexStringChecksummed(),
            '","balance":"',
            _erc721.balanceOf(_owner).toString(), // Updated to use LibString
            '","metadata":"',
            '"'
        );
    }

    /**
     * @dev Retrieves information about an ERC721 token.
     * @param _contract address of the ERC721 contract.
     * @return A string representation of the token information.
     */
    function getERC721Info(address _contract) internal view returns (bytes memory) {
        iERC721 _erc721 = iERC721(_contract);
        return abi.encodePacked(
            '"contract":"',
            _contract.toHexStringChecksummed(),
            '"erc":721,"name":"',
            _erc721.name(),
            '","supply":',
            getSupply(_contract),
            ',"symbol":"',
            _erc721.symbol()
        );
    }

    /**
     * @dev Retrieves the balance of an ERC721 token for a given address.
     * @param _contract address of the ERC721 contract.
     * @param _owner address to check the balance for.
     * @return A string representation of the balance.
     */
    function erc721Balance(address _contract, address _owner) internal view returns (string memory) {
        iERC721 _erc721 = iERC721(_contract);
        return string.concat(
            '"a":"',
            _owner.toHexStringChecksummed(),
            '","b":"',
            _erc721.balanceOf(_owner).toString(), // Updated to use LibString
            '","c":"',
            _contract.toHexStringChecksummed(),
            '","e":721,"t":"',
            getSupply(_contract).toString(), // Updated to use LibString
            '","s":"',
            _erc721.symbol(),
            '"'
        );
    }

    /**
     * @dev Retrieves the decimal places for an ERC20 token.
     * @param _erc20 ERC20 token contract.
     * @return A string representation of the decimal places.
     */
    function getDecimals(iERC20 _erc20) internal view returns (uint256) {
        try _erc20.decimals() returns (uint8 _decimals) {
            return _decimals;
        } catch {
            return 0;
        }
    }

    /**
     * @dev Retrieves the balance of an ERC20 token for a given address.
     * @param _token address of the ERC20 contract.
     * @param _owner address to check the balance for.
     * @return A string representation of the balance.
     */
    function getBalance(address _token, address _owner) internal view returns (uint256) {
        try iERC20(_token).balanceOf(_owner) returns (uint256 _bal) {
            return _bal;
        } catch {
            return 0;
        }
    }

    /**
     * @dev Retrieves the total supply of an ERC20 token.
     * @param _addr address of the ERC20 contract.
     * @return A string representation of the total supply.
     */
    function getSupply(address _addr) internal view returns (uint256) {
        try iERC20(_addr).totalSupply() returns (uint256 _supply) {
            return _supply;
        } catch {
            return 0;
        }
    }

    /**
     * @dev Checks if an ERC721 token exists for a given ID and address.
     * @param id ID of the token.
     * @param _erc721 address of the ERC721 contract.
     * @return owner of the token if it exists, otherwise address(0).
     */
    function idCheck721(address _erc721, uint256 id) internal view returns (address) {
        try iERC721(_erc721).ownerOf(id) returns (address _owner) {
            return _owner;
        } catch {
            return address(0);
        }
    }

    /**
     * @dev Retrieves the calldata for a given address and label.
     * @param _addr address to retrieve calldata for.
     * @param _label label to use for the calldata.
     * @return ok A boolean indicating success and the calldata as bytes.
     * @return _res calldata as bytes.
     */
    function getCalldata(address _addr, bytes memory _label) public view returns (bool ok, bytes memory _res) {
        //(ok, _res) = _addr.staticcall(string(_label).hexStringToBytes());
        if (ok) {
            if (
                _res.length > 0 && keccak256(abi.encodePacked(bytes32(_res))) != keccak256(abi.encodePacked(bytes32(0)))
            ) {
                _res = bytes(string.concat('"data":"', _res.toHexString(), '"'));
            } else {
                ok = false;
            }
        }
    }

    function getFeatured20(iERC20 erc20, uint256 balance) public view returns (bytes memory) {
        return abi.encodePacked(
            '"',
            erc20.symbol(),
            '":["',
            balance.toString(), // Updated to use LibString
            '","',
            address(erc20).toHexStringChecksummed(), // Ensure this is correct
            '","',
            erc20.decimals().toString(), // Updated to use LibString
            '","',
            erc20.totalSupply().toString(), // Updated to use LibString
            '"]'
        );
    }

    function getFeatured721(iERC721 erc721, uint256 balance) public view returns (bytes memory) {
        return abi.encodePacked(
            '"',
            erc721.symbol(),
            '":["',
            balance.toString(), // Updated to use LibString
            '","',
            address(erc721).toHexStringChecksummed(), // Ensure this is correct
            '","',
            iERC165(address(erc721)).supportsInterface(iERC2981.royaltyInfo.selector) ? "true" : "false",
            '","',
            erc721.totalSupply().toString(), // Updated to use LibString
            '","',
            iERC7572(address(erc721)).contractURI(), // TODO: use try catch for this
            '"]'
        );
    }
}
