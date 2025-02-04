# CreditorContract

В проекте реализован смарт-контракт, способный выдавать кредиты под залог.

Смарт-контракт принимает в качесвте залога ethereum, кол-во которого определяется в зависимости от суммы желаемого кредита.

И выдает в качестве займа токены на различные крипто-валюты

# Зависимости:

* truffle
* ganache
* Solidity (@openzeppelin/contracts/token/ERC20/ERC20.sol) 

# Запуск:

Запуск смарт-контрактов производится на основе сети ganache, к которой смарт-контракт подключается с помощью утилиты truffle

* ganache
* truffle test
* truffle compile --all
* truffle migrate --network development

