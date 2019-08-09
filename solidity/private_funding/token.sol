pragma solidity ^0.4.24;

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}


// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
// ----------------------------------------------------------------------------
contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function transfer(address to, uint tokens) public returns (bool success);
    
    event Transfer(address indexed from, address indexed to, uint tokens);
}

contract Owned {
    address public owner;

    event OwnershipTransfer(address from, address to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier onlyOwnerOrigin {
        require(tx.origin == owner);
        _;
    }

    function transferOwnership(address _owner) public onlyOwner {
        emit OwnershipTransfer(owner, _owner);
        owner = _owner;
    }
}

contract QelsToken is ERC20Interface, Owned {
    using SafeMath for uint;

    string public symbol;
    string public  name;
    uint8 public decimals;
    uint256 public tokenPerPrice;
    uint _totalSupply;

    mapping(address => uint) balances;
    
    event TokenPerPriceChanged(uint256 tokenPerPrice);
    
    function getSymbol() public view returns(string){
        return symbol;
    }
    
    function getName() public view returns(string){
        return name;
    }
    
    function getDecimals() public view returns(uint8){
        return decimals;
    }
    
    function getTokenPerPrice() public view returns(uint256){
        return tokenPerPrice;
    }
    function setTokenPerPrice(bool _isPlus, uint256 _amount) public onlyOwnerOrigin returns(uint256){
        if(_isPlus){
            tokenPerPrice.add(_amount);
        }else{
            tokenPerPrice.sub(_amount);
        }
        
        emit TokenPerPriceChanged(tokenPerPrice);
        return tokenPerPrice;
    }

    constructor(uint256 supply) public {
        symbol = "Qels";
        name = "Qels Token";
        _totalSupply = supply;
        balances[owner] = supply;
        tokenPerPrice = 1000;
        emit TokenPerPriceChanged(tokenPerPrice);
        emit Transfer(address(0), owner, _totalSupply);
    }


    function totalSupply() public view returns (uint) {
        return _totalSupply.sub(balances[address(0)]);
    }
    
    
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }


    function transfer(address to, uint256 tokens) public returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(msg.sender, to, tokens);
        
        return true;
    }

    function transferFromOwner(address to, uint256 tokens) public onlyOwner returns (bool){
        balances[owner] = balances[owner].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(owner, to, tokens);
        
        return true;
    } 

    function () external payable {
        revert();
    }
}
