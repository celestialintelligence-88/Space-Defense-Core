// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./CelestialPattern.sol";

contract ThreatDetector {
    CelestialPattern public immutable celestialPattern;
    address public admin;
    
    uint256 public constant CRITICAL_THRESHOLD = 25;
    uint256 public constant HIGH_THRESHOLD = 50;
    uint256 public constant MEDIUM_THRESHOLD = 75;
    
    mapping(address => bool) public authorizedCallers;
    
    event ThreatDetected(bytes32 indexed componentId, bytes32 indexed attackId, uint256 riskScore, uint256 timestamp);
    event CallerAuthorized(address indexed caller);
    
    modifier onlyAuthorized() {
        require(authorizedCallers[msg.sender] || msg.sender == admin, "Unauthorized caller");
        _;
    }
    
    constructor(address _celestialPatternAddress) {
        celestialPattern = CelestialPattern(_celestialPatternAddress);
        admin = msg.sender;
        authorizedCallers[msg.sender] = true;
    }
    
    function detectThreat(bytes32 componentId, uint256 sensorData) 
        external 
        onlyAuthorized 
        returns (bytes32 attackId, uint256 riskScore) 
    {
        attackId = keccak256(abi.encodePacked(componentId, sensorData, block.timestamp / 3600));
        riskScore = 100;
        
        if (sensorData > 1000) riskScore = 10;
        else if (sensorData > 500) riskScore = 25;
        else if (sensorData > 250) riskScore = 50;
        
        emit ThreatDetected(componentId, attackId, riskScore, block.timestamp);
        return (attackId, riskScore);
    }
    
    function authorizeCaller(address caller) external {
        require(msg.sender == admin, "Only admin");
        authorizedCallers[caller] = true;
        emit CallerAuthorized(caller);
    }
}
