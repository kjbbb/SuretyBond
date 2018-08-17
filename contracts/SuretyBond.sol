pragma solidity ^0.4.24;

contract SuretyBond {
    
    uint public price;
    uint public insurance_price;
    address public obligee;     //buyer receiving the goods
    address public principal;   //seller
    address public insurer;
    uint public maturation_interval;
    uint public instantiated_at;
    
    enum Stages {
        INIT,
        CLOSED
    }
    
    Stages public stage = Stages.INIT;
    
    constructor(uint _price, uint _insurance_price, address _obligee, address _principal, address _insurer, uint _maturation_interval) public {
        price = _price;
        insurance_price = _insurance_price;
        obligee = _obligee;
        principal = _principal;
        insurer = _insurer;
        maturation_interval = _maturation_interval;
        
        instantiated_at = now;
    }
    
    modifier isInsurer() {
        require(msg.sender == insurer);
        _;
    }
    
    modifier isPrincipal() {
        require(msg.sender == principal);
        _;
    }
    
    modifier isObligee() {
        require(msg.sender == obligee, "obligee");
        _;
    }
    
    function fund() public payable isInsurer {
        require(msg.value == price);
    }
    
    function buyPrice() public constant returns (uint) {
        return price + insurance_price;
    }
    
    function buy() public payable isObligee {
        require(msg.value == buyPrice());
        
        principal.transfer(price);
    }

    function approveInsuranceClaim() public isInsurer {
        obligee.transfer(price);
        insurer.transfer(insurance_price);
    }

    function obligeeFinish() public isObligee {
        insurer.transfer(this.balance);
    }

    function finish() public isInsurer {
        if (instantiated_at + maturation_interval > now) {
            insurer.transfer(this.balance);
        }
    }
}
