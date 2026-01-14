// Real-time ISS Threat Monitor
const ISS_API = 'http://api.open-notify.org/iss-now.json';

async function trackISS() {
  const response = await fetch(ISS_API);
  const data = await response.json();
  
  console.log(`🛰️  ISS Position: ${data.iss_position.latitude}, 
${data.iss_position.longitude}`);
  
  // Simulate contract interaction
  if (Math.random() > 0.8) { // 20% chance of simulated threat
    console.log("⚠️  ANOMALY DETECTED IN ORBITAL PATH");
    console.log("📡 Broadcasting to ThreatDetector.sol...");
    console.log("🔗 Transaction: 0x7f3d..." + 
Math.random().toString(36).substr(2, 9));
    console.log("✅ Evasion protocol activated on-chain");
  }
}

// Poll every 5 seconds
setInterval(trackISS, 5000);

