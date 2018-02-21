pragma solidity ^0.4.16 ;

contract NtuaToken {
	
	//EVENTS
    event Transfer(address indexed from, address indexed to, uint256 value) ;
	
    //METHODS
    //Constructor-Initializes contract with initial supply tokens to the creator of the contract
    function NtuaToken() {
        balanceOf[msg.sender] = 100000000 * 1 ether ;
        totalSupply = 100000000 * 1 ether ;
        name = "NTUA Token" ;
        symbol= "NTUATok" ;
        decimals = 18 ;
        owner = msg.sender ;
        price = 1000000000000000000 ;	//set initial price
    }
    
    //contract receives ethers and gives back tokens
    function () payable {
        if(msg.sender != owner) {
            uint256 amount = msg.value * 1000000000000000000  / price ;
            _transfer(owner, msg.sender, amount) ;
        }
    }
    
    //owner changes the price of the token
    function changePrice(uint _price) {
        require (msg.sender == owner) ;
        price = _price ;
    }
    
    //owner takes ethers from the contract
    function retrieveEthereum(uint256 amount) {
        require (msg.sender == owner) ;
        require(this.balance >= amount) ;
        owner.transfer(amount) ;
    }
    
    //token holders can sell  their tokens back to the owner of the contract
    function sellBack(uint256 amount, uint _price) {
        require(_price <= price) ;				//only sell the coins if the asking price is lower than the price of the token
        require(balanceOf[msg.sender] >= amount) ;
        uint256 totalEth = amount * price / 1000000000000000000 ;
        require(this.balance >= totalEth) ;
        _transfer(msg.sender, owner, amount) ;
        msg.sender.transfer(totalEth) ;
    }

    //Internal transfer, only can be called by this contract
    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != 0x0) ;								// Prevent transfer to 0x0 address. Use burn() instead
        require(balanceOf[_from] >= _value) ;				// Check if the sender has enough
        require(balanceOf[_to] + _value > balanceOf[_to]) ;	// Check for overflows
        balanceOf[_from] -= _value ;						// Subtract from the sender
        balanceOf[_to] += _value ;							// Add the same to the recipient
        Transfer(_from, _to, _value) ;
    }
    
    function transfer(address _to, uint256 _value) {
        _transfer(msg.sender, _to, _value) ;
    }
    
    function brokerTransferFrom(address _from, address _to, uint256 _value) returns (bool success) {
		require(msg.sender == 0xb1719bf761175017eeb6bb72423ece49914fef9b) ;		//the broker contract will never try to steal, we trust it
        _transfer(_from, _to, _value) ;
        return true ;
    }
	
	//FIELDS
    string public name ;				//name of the token
    string public symbol ;				//symbol of the token
    uint8 public decimals ;				//decimals of the token
    uint256 public totalSupply ;		//total supply of the token
    address public owner ;				//the owner of the contract
    uint256 public price ;				//price of one ntua Token in ethereum
	//The array with all balances
	mapping (address => uint256) public balanceOf ;
}