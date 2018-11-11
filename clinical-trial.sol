pragma solidity 0.4.25;

contract ActorContract{

    enum ActorType{pharma,subject,cro,regulatory,invalid}
    
    address govContractAddr;
    
    struct Pharma{
        string name;
        uint16 registrationNo;
    }
    
    struct TestSubject{
        string name;
    }
    
    struct Cro{
        string name;
    }
    struct Regulatory{
        string name;
    }
    
    mapping(address => ActorType) roles;
    
    mapping(address => Pharma) pharma;
    mapping(address => Regulatory) regulatories;
    mapping(address => TestSubject) testSubjects;
    mapping(address => Cro) cros;

    modifier onlyGovContract(){
        require(msg.sender == govContractAddr);
        _;
    }
    
    // what's protecting this method from being executed by anyone ?
    function setGovContractAddr(address _addr) public returns(bool){
        require(govContractAddr == 0x0); // should be executed once only
        govContractAddr = _addr;
    }
    
    function registerActor(string _name,address _addr,ActorType actorType) onlyGovContract public returns(bool){
        roles[_addr] = actorType;
        
        if(actorType == ActorType.cro){
            cros[_addr] = Cro(_name);
        }else if(actorType == ActorType.regulatory){
            regulatories[_addr] = Regulatory(_name);
        }else if(actorType == ActorType.subject){
            testSubjects[_addr] = TestSubject(_name);
        }
        
        return true;
    }
    
    function registerPharma(string _name,address _addr,uint16 _registrationNo) onlyGovContract public returns(bool){
        roles[_addr] = ActorType.pharma;
        pharma[_addr] = Pharma(_name,_registrationNo);
    }
    
    function getActorType(address _addr) public view returns(ActorType){
        ActorType actorType = roles[_addr];

       if(actorType == ActorType.cro){
            return ActorType.cro;
        }else if(actorType == ActorType.regulatory){
            return ActorType.regulatory;
        }else if(actorType == ActorType.subject){
            return ActorType.subject;
        }else if(actorType == ActorType.pharma){
            return ActorType.pharma;
        }
        return ActorType.invalid;
    }
    
    function getPharmaDetails(address _addr) public view returns(string){
        return pharma[_addr].name;
    }
    
}

contract GovContract{
    address public owner;
    
    ActorContract actorContract;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    constructor(address actorContractAddress) public {
        owner = msg.sender;
        actorContract = ActorContract(actorContractAddress);
        actorContract.setGovContractAddr(this);
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    modifier onlyPharma(){
        require(actorContract.getActorType(msg.sender) == ActorContract.ActorType.pharma);
        _;
    }
    
    modifier onlyRegulatory(){
        require(actorContract.getActorType(msg.sender) == ActorContract.ActorType.regulatory);
        _;
    }
    
    modifier onlyCRO(){
        require(actorContract.getActorType(msg.sender) == ActorContract.ActorType.cro);
        _;
    }
    
    modifier onlySubject(){
        require(actorContract.getActorType(msg.sender) == ActorContract.ActorType.subject);
        _;
    }
    
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
  
    function registerCRO(string _name,address _addr) public onlyRegulatory returns(bool){
        actorContract.registerActor(_name,_addr,ActorContract.ActorType.cro);
        return true;   
    }
    
    function registerTestSubject(string _name,address _addr) public onlyCRO returns(bool){
        actorContract.registerActor(_name,_addr,ActorContract.ActorType.subject);
        return true;
    }
}

