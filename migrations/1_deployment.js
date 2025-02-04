const Bitcoin = artifacts.require("Bitcoin");
const XRP = artifacts.require("XRP");
const Tether = artifacts.require("Tether");
const BinanceCoin = artifacts.require("BinanceCoin");
const CreditorContract = artifacts.require("CreditorContract");

module.exports = function (deployer) {
	let token1, token2, token3, token4;
	const creditorAddress = "0xe88793275837234A5fcF670078c983d512fAAB22";
    deployer.deploy(Bitcoin)
      	.then(instance => {
        	console.log("BTC deployed at address: ", instance.address);
			token1 = instance.address;
      	})
      	.then(() => {
        	return deployer.deploy(XRP);
      	})
      	.then(instance => {
    		console.log("XRP deployed at address: ", instance.address);
			token2 = instance.address;
      	})
    	.then(() => {
      		return deployer.deploy(Tether);
    	})
    	.then(instance => {
      		console.log("USDT deployed at address: ", instance.address);
			token3 = instance.address;
    	})
    	.then(() => {
      		return deployer.deploy(BinanceCoin);
    	})
    	.then(instance => {
      		console.log("BNB deployed at address: ", instance.address);
			token4 = instance.address;
		})
		.then(() => {
			return deployer.deploy(CreditorContract, creditorAddress, token1, token2, token3, token4);
		})
		.then(instance => {
			console.log("CreditorConstract deployed at address: ", instance.address);
			return instance.address;
		});
};
