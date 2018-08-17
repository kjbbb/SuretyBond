var SuretyBond = artifacts.require("SuretyBond");

contract('SuretyBond', function(accounts) {

        const price = web3.toWei(10, 'ether')
        const insurance_price = web3.toWei(4, 'ether')
        const obligee = accounts[1]     //buyer
        const principal = accounts[2]   //seller
        const insurer = accounts[3]     //insurer
        const seconds_to_maturation = 10


    beforeEach(async function() {
        this.bond = await SuretyBond.new(price, insurance_price, obligee, principal, insurer, seconds_to_maturation)
    })

    it('buy success workflow', async function() {

        //record initial balances
        const obligeeInitialBalance = await web3.eth.getBalance(obligee)
        const principalInitialBalance = await web3.eth.getBalance(principal)
        const insurerInitialBalance = await web3.eth.getBalance(insurer)

        //insurer funds the bond with the required amount
        const _price = await this.bond.price.call({from: insurer})
        await this.bond.fund({from: insurer, value: _price})
        const contractBalance = await web3.eth.getBalance(this.bond.address)

        assert(_price.toString() == contractBalance.toString())

        //buyer buys it
        const _buyPrice = await this.bond.buyPrice.call({from: obligee})
        await this.bond.buy({from: obligee, value: _buyPrice})

        //make sure seller received 100% of the price of the item
        const _principalBalance = await web3.eth.getBalance(principal)
        const diff = _principalBalance.minus(principalInitialBalance)
        assert(diff.toString() == price)

        //buyer is happy with the item
        await this.bond.obligeeFinish({from: obligee})

        //make sure insurer made a profit
        //const insurerFinal = await web3.eth.getBalance(insurer)
        //assert(insurerFinal.isGreaterThan(insurerInitialBalance))

        //make sure the contract is now empty
        const _contractBalance = web3.eth.getBalance(this.bond.address)
        assert(_contractBalance.toString() == 0)
    })

    it('buy insurance claim workflow', async function() {

        //record initial balances
        const obligeeInitialBalance = await web3.eth.getBalance(obligee)
        const principalInitialBalance = await web3.eth.getBalance(principal)
        const insurerInitialBalance = await web3.eth.getBalance(insurer)

        //insurer funds the bond with the required amount
        const _price = await this.bond.price.call({from: insurer})
        await this.bond.fund({from: insurer, value: _price})
        const contractBalance = await web3.eth.getBalance(this.bond.address)

        //buyer buys it
        const _buyPrice = await this.bond.buyPrice.call({from: obligee})
        await this.bond.buy({from: obligee, value: _buyPrice})

        //make sure seller received 100% of the price of the item
        const _principalBalance = await web3.eth.getBalance(principal)
        const diff = _principalBalance.minus(principalInitialBalance)
        assert(diff.toString() == price)

        //insurer processes the claim and refunds the buyer with their money
        await this.bond.approveInsuranceClaim({from: insurer})
    })
})
