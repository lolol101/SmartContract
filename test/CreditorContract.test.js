const Bitcoin = artifacts.require("Bitcoin");
const XRP = artifacts.require("XRP");
const Tether = artifacts.require("Tether");
const BinanceCoin = artifacts.require("BinanceCoin");
const CreditorContract = artifacts.require("CreditorContract");
const BN = web3.utils.BN;

contract("CreditorContract", (accounts) => {
    let creditor, btc, xrp, usdt, bnb;


    const lender = accounts[0];
    const borrower = accounts[1];

    before(async() => {
        btc = await Bitcoin.new();
        xrp = await XRP.new();
        usdt = await Tether.new();
        bnb = await BinanceCoin.new();
        creditor = await CreditorContract.new(lender, btc.address, xrp.address, usdt.address, bnb.address);
    });

    it("Calculate deposit correctly", async() => {
        const secondsNumber = 10;
        const loan = web3.utils.toWei("1", "ether"); // 1 BTC
        const currencyType = 0;
        const deposit = await creditor.calcDeposit(secondsNumber, loan, currencyType);

        assert(deposit == 1.44 * 10 ** 18 * 29.580631, "Deposit should be greater than zero");
    });

    it("Allow a borrower to request a loan", async () => {
        const secondsNumber = 10;
        const loan = web3.utils.toWei("1", "ether"); // 1 BTC
        const currencyType = 0;
        const deposit = await creditor.calcDeposit(secondsNumber, loan, currencyType);

        const lenderBalanceBefore = await web3.eth.getBalance(creditor.address);

        const _ = await creditor.loanRequest(secondsNumber, loan, currencyType, {
            from: borrower,
            value: deposit,
        });

        const lenderBalanceAfter = await web3.eth.getBalance(creditor.address);
        const loanInfo = await creditor.getLoanInfo({ from: borrower });

        assert.equal(loanInfo.loan, loan, "Loan should be correctly recorded");
        assert.equal(loanInfo.debtLeft, deposit, "Deposit should be correctly recorded");
        assert.isTrue((await btc.balanceOf(borrower)).eq(new BN("1000000000000000000")), "Loan should be given");
        assert.equal(lenderBalanceAfter - deposit, lenderBalanceBefore);
    });

    it("Allow loan payment and reduce debt", async () => {
            const paymentAmount = web3.utils.toWei("0.5", "ether");
            const debtBefore = (await creditor.getLoanInfo({ from: borrower })).debtLeft;

            await creditor.loanPayment({
                from: borrower,
                value: paymentAmount,
            });

            const debtAfter = (await creditor.getLoanInfo({ from: borrower })).debtLeft;
            assert.equal(debtAfter, debtBefore - paymentAmount, "Debt should decrease after payment");
    });

    it("Free borrower after full payment", async () => {
        const remainingDebt = (await creditor.getLoanInfo({ from: borrower })).debtLeft;

        await creditor.loanPayment({
            from: borrower,
            value: remainingDebt
        });
    
        assert.equal(await creditor.checkRegistration({ from: borrower }), false, "Borrower should be free after full payment");
    });

    function sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    it("Too late to pay)", async () => {
        try {
            const secondsNumber = 1;
            const loan = web3.utils.toWei("1", "ether"); // 1 BTC
            const currencyType = 0;
            const deposit = await creditor.calcDeposit(secondsNumber, loan, currencyType);

            const _ = await creditor.loanRequest(secondsNumber, loan, currencyType, {
                from: borrower,
                value: deposit,
            });

            const remainingDebt = (await creditor.getLoanInfo({ from: borrower })).debtLeft;

            console.log("Start");
            await sleep(2000);
            console.log("Waited for 2 seconds");
            console.log("End");

            
            await creditor.loanPayment({
                from: borrower,
                value: remainingDebt
            });

            assert.isTrue(false);

            // A user with an overdue payment remains registered so he won't be able to have another loan!!!

        } catch (error) {
            expect(error.message).to.include("Too late to pay)");
        }
    });
});
