pragma solidity ^0.4.24;

contract SuretyBond {
    
    uint public price;
    uint public insurance_price;
    address public obligee;     //buyer receiving the goods
    address public principal;   //seller
    address public insurer;
    uint public seconds_to_maturation;
    uint public instantiated_at;
    
    enum States {
        INIT,
        FUNDED,
        BOUGHT,
        CLOSED
    }
    
    States public state = States.INIT;
    
    constructor(uint _price, uint _insurance_price, address _obligee, address _principal, address _insurer, uint _seconds_to_maturation) public {
        price = _price;
        insurance_price = _insurance_price;
        obligee = _obligee;
        principal = _principal;
        insurer = _insurer;
        seconds_to_maturation = _seconds_to_maturation;
        
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

    modifier reqState(States s) {
        require(state == s);
        _;
    }
    
    function fund() public payable isInsurer reqState(States.INIT) {
        require(msg.value == price);

        state = States.FUNDED;
    }
    
    function buyPrice() public constant returns (uint) {
        return price + insurance_price;
    }
    
    function buy() public payable isObligee reqState(States.FUNDED) {
        require(msg.value == buyPrice());

        state = States.BOUGHT;
        principal.transfer(price);
    }

    function approveInsuranceClaim() public isInsurer reqState(States.BOUGHT) {
        state = States.CLOSED;
        obligee.transfer(price);
        insurer.transfer(insurance_price);
    }

    function obligeeFinish() public isObligee reqState(States.BOUGHT) {
        state = States.CLOSED;
        insurer.transfer(this.balance);
    }

    function finish() public isInsurer reqState(States.BOUGHT) {
        if (instantiated_at + seconds_to_maturation > now) {
            state = States.CLOSED;
            insurer.transfer(this.balance);
        }
    }
}
