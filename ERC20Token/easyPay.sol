pragma solidity 0.4.25;

interface ERC20Token {
    
    function totalSupply() public view returns (uint256 amount);
    function balanceOf(address owner) public view returns (uint256 amount);
    function transfer(address to, uint256 amount) public returns (bool success);
    function approve(address spender, uint256 amount) public returns (bool success);
    function transferFrom(address owner, address to, uint256 amount) public returns (bool success);
    function allowance(address spender) public view returns (uint256 amount);

}

contract EasyPayToken is ERC20Token {
    
    //state variables    
    string name = "EasyPayToken";
    string symbol = "EZP";
    uint8 tokensPerUnitOfEther = 10;
    address owner; // owner of the tokens
    uint256 TotalSupply; // to add more supply just add to this
    uint256 totalWeiInSystem;
    
    mapping( address => uint256 ) balances;
    mapping( address =>  mapping( address => uint256 ) ) allowed;

    event Transfer(address from, address to,uint256 amount);
    event Approval(address from, address to, uint256 amount);
    
    constructor () public {
        owner = msg.sender;
        TotalSupply = 1000000000000000000000000;
        totalWeiInSystem = 0;
        balances[owner] = 1000000000000000000000000;
    }
    
    function totalSupply() public view returns (uint256 amount){
        return TotalSupply;
    }

    function balanceOf(address owner) public view returns (uint256 amount){
        return balances[owner];
    }
    /* if require fails Gas will be returned as not opertaion 
        if assert fails Gas will not be returned
    */
    function transfer(address to, uint256 amount) public returns (bool success){
        require(to != 0x0); 
        require(amount > 0);
        require(balances[msg.sender] > amount);
        require(balances[to] + amount > amount); // integer overflow
        
        balances[msg.sender] -= amount;
        balances[to] += amount;
        
        assert(balances[to] >= amount);
        
        emit Transfer(msg.sender,to,amount);
        return true;
    }
    function approve(address spender, uint256 amount) public returns (bool success){
        allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender,spender,amount);
        return true;
    }
    
    function allowance(address spender) public view returns (uint256 amount){
        return allowed[msg.sender][spender];
    }
    
    function transferFrom(address owner, address to, uint256 amount) public returns (bool success){
        
        require(to != 0x0); 
        require(owner != 0x0); 
        require(amount > 0);
        require(balances[owner] > amount);
        require(balances[to] + amount > amount); // integer overflow
        require(allowed[owner][msg.sender] >= amount);
        
        balances[owner] -= amount;
        balances[to] += amount;
        allowed[owner][msg.sender] -= amount;
        
        assert(balances[to] >= amount);
        
        emit Transfer(owner,to,amount);
        return true;
    }
    
    function () payable{
        
        totalWeiInSystem += msg.value;
        uint256 tokens = msg.value * tokensPerUnitOfEther;
        
        balances[owner] -= tokens;
        balances[msg.sender] += tokens;
        
        emit Transfer(owner,msg.sender,tokens);
        
        owner.transfer(msg.value);
    }
}
