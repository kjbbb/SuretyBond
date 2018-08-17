var SuretyBond = artifacts.require("SuretyBond");

contract('SuretyBond', function(accounts) {

    beforeEach(async function() {
        const price = web3.toWei(10, 'ether')
        const insurance_price = web3.toWei(4, 'ether')
        const obligee = accounts[1]
        const principal = accounts[2]
        const insurer = accounts[3]
        const seconds_to_maturation = 10

        this.bond = await SuretyBond.new(price, insurance_price, obligee, principal, insurer, seconds_to_maturation)
    })

    it('test2', async function() {
        //const price = await this.bond.price.call()
        //console.log(web3.fromWei(price.toString(), 'ether'))
    })
})
