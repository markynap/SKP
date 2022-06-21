//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

interface ISKP is IERC20 {
    function mint(address to, uint256 amount) external;
    function burnFrom(address account, uint256 amount) external returns (bool);
}

interface ISKPNFT is IERC721 {
    function getIDsByOwner(address owner) external view returns (uint256[] memory);
}

/**
    Vault Contract Handles The Conversion Between ERC721 Tokens and ERC20 Tokens
    As Specified By The `Conversion Rate`
 */
contract Vault is IERC721Receiver {

    // SKP Token
    ISKP public SKP;

    // SKP NFT
    ISKPNFT public immutable SKPNFT;

    // 1 NFT < == > x Tokens
    uint256 public constant conversionRate = 20_000 * 10**18;

    // Initialize NFT
    constructor(address NFT) {
        SKPNFT = ISKPNFT(NFT);
    }

    function initializeSKP(address SKP_) external {
        require(SKP_ != address(0), 'Invalid Param');
        require(address(SKP) == address(0), 'Already Initialized');
        SKP = ISKP(SKP_);
    }

    function convertNFTToERC(uint256 tokenID) external {
        require(
            SKPNFT.ownerOf(tokenID) == msg.sender,
            'Sender Must Be NFT Owner'
        );

        // transfer from sender to this
        SKPNFT.safeTransferFrom(msg.sender, address(this), tokenID);

        // ensure transfer was successful
        require(
            SKPNFT.ownerOf(tokenID) == address(this),
            'Did Not Receive NFT'
        );

        // mint sender SKP Tokens 
        SKP.mint(msg.sender, conversionRate);
    }

    function convertERCToNFT() external {

        // number of SKP tokens to burn
        uint tokensToBurn = conversionRate;
        
        // fetch user balance before burn
        uint balBefore = SKP.balanceOf(msg.sender);
        require(
            balBefore >= tokensToBurn,
            'Insufficient Tokens'
        );

        // fetch total supply before burn
        uint totalBefore = SKP.totalSupply();

        // burn tokens from sender
        require(
            SKP.burnFrom(msg.sender, tokensToBurn),
            'Error Burning Tokens'
        );

        // fetch total supply after burn
        uint totalAfter = SKP.totalSupply();
        require(
            totalBefore > totalAfter,
            'Zero Burned' 
        );

        // check balance after
        uint balAfter = SKP.balanceOf(msg.sender);
        require(
            balBefore > balAfter,
            'Zero Burned'
        );

        // ensure correct amount was burned
        uint nBurned = balBefore - balAfter;
        uint tBurned = totalBefore - totalAfter;
        require(
            nBurned == tokensToBurn &&
            tBurned == tokensToBurn,
            'Error Burning Tokens'
        );

        // transfer NFT to owner
        uint256[] memory IDs = SKPNFT.getIDsByOwner(address(this));
        uint256 IDLength = IDs.length;
        require(
            IDLength > 0,
            'Zero NFTs Stored'
        );

        // transfer pseudo-random NFT in list to owner
        // randomness is not too important here
        uint p = uint256(blockhash(block.number)) % IDLength;
        uint idToSend = IDs[p];

        // save memory by deleting IDs
        delete IDs;

        // send NFT to msg.sender
        SKPNFT.safeTransferFrom(address(this), msg.sender, idToSend);
    }

    /**
        Total number of NFTs Locked
     */
    function NFTsLocked() public view returns (uint256) {
        return SKPNFT.balanceOf(address(this));
    }


    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external returns (bytes4) {
        return IERC721.onERC721Received.selector;
    }


}