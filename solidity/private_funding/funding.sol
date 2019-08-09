pragma solidity ^0.4.24;

contract QelsToken {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function transfer(address to, uint tokens) public returns (bool success);
    function setTokenPerPrice(bool _isPlus, uint256 _amount) public returns(uint256);
    
    event Transfer(address indexed from, address indexed to, uint tokens);
}

contract ElsContract{
    
    function abs(uint256 num1, uint256 num2) public pure returns(bool, uint256) {
        if(num1 < num2) {
            return (true,  100 - (num1) / (num2/100));
        } else {
            return (false, 100 -(num2) / (num1/100));
        }
    }

    address owner;
    address founder;
    address investor;
    QelsToken token;
    
    // 기본 정보
    string secName; // 증권의 명칭
    string stockCode; // 증권 코드
    uint256 startPrice; // 납입일 증권 가격
//    uint256 expirationPrice; // 만기일 증권 가격
    uint8  duesPerYear; // 연 이자율
    uint8 fundingYears; // 투자 기간
    uint256 notionalAmount; // 액면금액
    uint256 issueAmount; // 발행가액
    uint32 issueDate; // 발행일
    uint32 expiryDate; // 만기일
    uint32 underPerPrice; // 하한선  percent

    modifier isExpire{
        require(block.timestamp > expiryDate);
        _;
    }
    
    function getInform() public view returns(string, string, uint8, uint256,
                                        uint256, uint32, uint32, uint32) {
                                            
        return(secName, stockCode, duesPerYear, notionalAmount, issueAmount, issueDate, expiryDate, underPerPrice);     
        
    }
    
    
    event QelsBuilt(address founder, address investor, address token);
    event QelsTradeSet(string secName, string stockCode, uint256 startPrice, uint8 duesPerYear, uint256 notionalAmount, uint256 issueAmout, uint32 issueDate, uint32 expiryDate, uint32 underPerPrice);
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    constructor(address _founder, address _investor, address _tokenAddr,string _secName, string _stockCode, uint256 _startPrice, uint8 _duesPerYear, uint8 _fundingYears,
                uint256 _notionalAmount, uint256 _issueAmout, uint32 _issueDate, uint32 _expiryDate, uint32 _underPerPrice) public {
        owner = msg.sender;
        founder = _founder;
        investor = _investor;
        token = QelsToken(_tokenAddr);
        
        secName = _secName;
        stockCode = _stockCode;
        startPrice = _startPrice;
        duesPerYear = _duesPerYear;
        fundingYears = _fundingYears;
        notionalAmount = _notionalAmount;
        issueAmount = _issueAmout;
        issueDate = _issueDate;
        expiryDate = _expiryDate;
        underPerPrice = _underPerPrice;
        
        token.transfer(investor, issueAmount);
        emit QelsTradeSet(secName, stockCode, startPrice, duesPerYear, notionalAmount, issueAmount, issueDate, expiryDate, underPerPrice);
        emit QelsBuilt(founder, investor, token);
    }
    
    function calcDues(uint256 expirationPrice) public isExpire returns(bool) {
        bool isPlus;
        uint256 gap;
        (isPlus, gap) = abs(startPrice, expirationPrice);
        
        if(isPlus){                         
            token.setTokenPerPrice(true, (duesPerYear * fundingYears)); // fund is up
        }else{
            //fund is down
            if(gap >underPerPrice){ // fund is down underPerPrice
                token.setTokenPerPrice(false, (gap*10)); 
            }else{
                token.setTokenPerPrice(true, duesPerYear * fundingYears);
            }
        }
    }
}

