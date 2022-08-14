// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Vault {

//PARTE VAULT

    address tokenAddress;
    address owner;

    // userAddress => tokenAddress => token amount
    mapping (address => mapping (address => uint256)) public userTokenBalance;

    constructor(address _tokenAddress) {
        tokenAddress = _tokenAddress;
        owner = msg.sender;
    }
     
    

    event tokenDepositComplete(address tokenAddress, uint256 amount);

    function depositToken( uint256 amount) public  {
        // require(whitelistedAdresses[address]==true,"ERROR")
        //require(IERC20(tokenAddress).balanceOf(msg.sender) >= amount, "Your token amount must be greater then you are trying to deposit");
        //require(IERC20(tokenAddress).approve(address(this), amount));
        //require(IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount));

        userTokenBalance[msg.sender][tokenAddress] += amount;
        emit tokenDepositComplete(tokenAddress, amount);
    }

    event tokenWithdrawalComplete(address tokenAddress, uint256 amount);

    function withDrawAll() public {
        //require(userTokenBalance[msg.sender][tokenAddress] > 0, "User doesnt has funds on this vault");
        uint256 amount = userTokenBalance[msg.sender][tokenAddress];
        //require(IERC20(tokenAddress).transfer(msg.sender, amount), "the transfer failed");
        userTokenBalance[msg.sender][tokenAddress] = 0;
        emit tokenWithdrawalComplete(tokenAddress, amount);
    }

    function withDrawAmount(uint256 amount) public {
        //require(userTokenBalance[msg.sender][tokenAddress] >= amount);
        //require(IERC20(tokenAddress).transfer(msg.sender, amount), "the transfer failed");
        userTokenBalance[msg.sender][tokenAddress] -= amount;
        emit tokenWithdrawalComplete(tokenAddress, amount);
    }

    function getTokenTotalLockedBalance(address _token) view external returns (uint256) {
       return IERC20(_token).balanceOf(address(this));
    }


//PARTE WHITELIST

    modifier onlyOwner(){
        require(msg.sender == owner, "Not Owner!!");
        _;
    }

    //A partir de la dirección retorna un T/F dependiendo de si esta a la WL
    mapping(address =>bool) whitelistedAddresses;
    

    //Añadir usuario a la WL publica, uso exclusivo del owner
    function addUser(address _addressToWL) public onlyOwner {
        whitelistedAddresses[_addressToWL] = true;
    }

    function disableUser(address _addressOut) public onlyOwner {
        whitelistedAddresses[_addressOut]= false;
    }

    // Verificar si el usuario pertenece en la WL, retorna T/F
    function isInWhitelist(address _whitelistedAddress) public view returns(bool) {
        bool userIsWhitelisted = whitelistedAddresses[_whitelistedAddress];
        return userIsWhitelisted;
    }
    
    modifier isWhitelisted(address _address) {
        require(whitelistedAddresses[_address], "You need to be whitelisted");
        _;
    }

}
