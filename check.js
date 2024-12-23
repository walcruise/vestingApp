require('dotenv').config();
console.log("Checking your setup...");
console.log("RPC URL:", process.env.SEPOLIA_RPC_URL ? "✅ Found" : "❌ Missing");
console.log("Private Key:", process.env.PRIVATE_KEY ? "✅ Found" : "❌ Missing");
console.log("Etherscan Key:", process.env.ETHERSCAN_API_KEY ? "✅ Found" : "❌ Missing");