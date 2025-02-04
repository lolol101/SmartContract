// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Биткойн (Bitcoin, BTC)
// Эфириум (Ethereum, ETH)
// Риппл (XRP)
// Тетра (Tether, USDT)
// Бинанс Коин (Binance Coin, BNB)

import "../ABDKMath64x64.sol";
import "./TokenContracts.sol";

contract CreditorContract {
    using ABDKMath64x64 for int128;

    struct Borrower {
        uint256 loan;
        uint256 debtLeft;
        uint256 endTime;
    }

    event LoanPayment(address indexed borrower, uint256 remainingDebt);

    address private lender;
    mapping(address => Borrower) private borrowers;
    mapping(address => bool) private isRegistered;
    mapping(uint => ERC20) private tokens;
    Bitcoin private BTCtoken;
    XRP private XRPtoken;
    BinanceCoin private BNBtoken;
    Tether private USDTtoken;

    modifier onlyBorrower() {
        require(isRegistered[msg.sender], "You are not registred!");
        _;
    }

    constructor(address lender_, address token1, address token2, address token3, address token4) {
        lender = lender_;
        BTCtoken = Bitcoin(token1);
        XRPtoken = XRP(token2);
        USDTtoken = Tether(token3);
        BNBtoken = BinanceCoin(token4);
        tokens[0] = BTCtoken;
        tokens[1] = XRPtoken;
        tokens[2] = USDTtoken;
        tokens[3] = BNBtoken;
        BTCtoken.mintToCreator(address(this));
        XRPtoken.mintToCreator(address(this));
        USDTtoken.mintToCreator(address(this));
        BNBtoken.mintToCreator(address(this));
    }

    function calculateLoanRatio(int128 secondsNumber) private pure returns(int128) {
        if (secondsNumber < 604800) 
            return ABDKMath64x64.div(144, 100);
        int128 ratio = ABDKMath64x64.
            add(ABDKMath64x64.
                sqrt(ABDKMath64x64.
                    div(ABDKMath64x64.fromInt(secondsNumber), ABDKMath64x64.fromUInt(604800))), 1);
        return ABDKMath64x64.toInt(ratio);
    }

    function getCurrencyDiff(uint currencyType) private view returns(uint256) {
        uint256 currencyDiff;
        if (currencyType == 0) {
            currencyDiff = BTCtoken.getCurrency();
        } else if (currencyType == 1) {
            currencyDiff = XRPtoken.getCurrency();
        } else if (currencyType == 2) {
            currencyDiff = USDTtoken.getCurrency();
        } else if (currencyType == 3) {
            currencyDiff = BNBtoken.getCurrency();
        }
        return currencyDiff;
    }

    // returns amount of money deposit is required
    function calcDeposit(int128 secondsNumber, uint256 loan, uint currencyType) public view returns(uint256) {
        require(secondsNumber > 0 && secondsNumber <= 312 * 604800 && currencyType < 4);
        return ABDKMath64x64.toUInt(
            ABDKMath64x64.mul(
                calculateLoanRatio(secondsNumber),
                    ABDKMath64x64.fromUInt(loan))) * getCurrencyDiff(currencyType) / 1e18;
    }

    function loanRequest(int128 secondsNumber, uint256 loan, uint currencyType) public payable {
        require(isRegistered[msg.sender] == false, "You already have a loan");
        require(tokens[currencyType].balanceOf(address(this)) >= loan, "Too high loan to request");
        require(secondsNumber > 0 && secondsNumber <= 312 * 604800 && currencyType < 4, "Incorrect arguments");
        require(msg.value == calcDeposit(secondsNumber, loan, currencyType), "Must send appropriate ETH amount");

        isRegistered[msg.sender] = true;
        borrowers[msg.sender] = Borrower({
            loan: loan,
            debtLeft: calcDeposit(secondsNumber, loan, currencyType),
            endTime: block.timestamp + ABDKMath64x64.toUInt(secondsNumber)
        });

        tokens[currencyType].transfer(msg.sender, loan);
    }

    // returns debtLeft value for borrower
    function loanPayment() public onlyBorrower payable {
        require(borrowers[msg.sender].endTime >= block.timestamp, "Too late to pay)");
        require(msg.value <= borrowers[msg.sender].debtLeft, "Your payment higher then debt!");

        borrowers[msg.sender].debtLeft -= msg.value;

        if (borrowers[msg.sender].debtLeft == 0) {
            delete borrowers[msg.sender];
            delete isRegistered[msg.sender];
            emit LoanPayment(msg.sender, 0);
        }
    }

    function getLoanInfo() public view returns(Borrower memory) {
        require(isRegistered[msg.sender] == true, "You are not registred");
        return borrowers[msg.sender];
    }

    function checkRegistration() public view returns(bool) {
        return isRegistered[msg.sender];
    }
}
