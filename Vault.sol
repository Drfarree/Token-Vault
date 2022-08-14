// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";


contract Vault {
    

    using SafeERC20 for IERC20;
    IERC20 public  token;

    uint public totalSupply;
    address owner;
    mapping(address => uint) public balanceOf;

    constructor(address _token) {
        token = IERC20(_token);
        owner = msg.sender;
    }

    //WHITELIST

    modifier onlyOwner(){
        require(msg.sender == owner, "Not Owner!!");
        _;
    }

    //A partir de la dirección retorna un T/F dependiendo de si esta a la WL
    mapping(address =>bool) public whitelistedAddresses;
    

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


/////////////////////////////////////////////////////////

    //VAULT

    
    function _mint(address _to, uint _shares) private {
        totalSupply += _shares;
        balanceOf[_to] += _shares;
    }

    function _burn(address _from, uint _shares) private {
        totalSupply -= _shares;
        balanceOf[_from] -= _shares;
    }
   //Añado funcion burn i mint para agregar o quitar tokens dels contrato


    function deposit(uint _amount) external {
        require(whitelistedAddresses[msg.sender] == true, "ERROR not in WL");

       // shares puede ser sustituido por otros calculos distintos
        uint shares;
        if (totalSupply == 0) {
            shares = _amount;
        } else {
            shares = (_amount * totalSupply) / token.balanceOf(address(this));
        }

        _mint(msg.sender, shares);
        token.transferFrom(msg.sender, address(this), _amount);
        
    }

    //Falta añadir que solo pueden retirar lo que han depositado. --> require?

    function withdraw(uint _shares) external {
        //Quien ejecute tiene que estar dentro de la whitelist
        
        require(whitelistedAddresses[msg.sender] == true, "ERROR not in WL");
        require (balanceOf[msg.sender] == _shares, "not this amount" );
    
        uint amount = (_shares * token.balanceOf(address(this))) / totalSupply;
        _burn(msg.sender, _shares);
        token.transfer(msg.sender, amount);
    }

}
