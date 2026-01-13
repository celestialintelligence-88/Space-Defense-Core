// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

contract CelestialPattern {
    mapping(bytes32 => bytes32) public encryptedPatterns;
    mapping(address => uint256) public subscriberExpiry;
    mapping(bytes32 => uint256) public patternFrequency;
    
    address public admin;
    uint256 public subscriptionDuration = 365 days;
    uint256 public subscriptionFee = 0.01 ether;
    bool public paused;
    
    event PatternStored(bytes32 indexed attackId, uint256 frequency);
    event SubscriberAdded(address indexed spacecraft, uint256 expiryTime);
    event EmergencyPause(address indexed triggeredBy);
    
    modifier onlySubscriber() {
        require(subscriberExpiry[msg.sender] > block.timestamp, "Subscription expired");
        _;
    }
    
    modifier onlyAdmin() {
        require(msg.sender == admin, "Unauthorized");
        _;
    }
    
    modifier notPaused() {
        require(!paused, "System paused");
        _;
    }
    
    constructor() {
        admin = msg.sender;
    }
    
    function subscribe() external payable notPaused {
        require(msg.value >= subscriptionFee, "Insufficient fee");
        subscriberExpiry[msg.sender] = block.timestamp + subscriptionDuration;
        emit SubscriberAdded(msg.sender, subscriberExpiry[msg.sender]);
    }
    
    function storePattern(bytes32 attackId, bytes32 encryptedData) external onlySubscriber notPaused {
        encryptedPatterns[attackId] = encryptedData;
        patternFrequency[attackId]++;
        emit PatternStored(attackId, patternFrequency[attackId]);
    }
    
    function getPattern(bytes32 attackId) external view onlySubscriber returns (bytes32) {
        return encryptedPatterns[attackId];
    }
    
    function emergencyPause() external onlyAdmin {
        paused = true;
        emit EmergencyPause(msg.sender);
    }
    
    function unpause() external onlyAdmin {
        paused = false;
    }
    
       function withdraw() external onlyAdmin {
    (bool success, ) = payable(admin).call{value: address(this).balance}("");
    require(success, "Withdrawal failed");
}
 
    }

