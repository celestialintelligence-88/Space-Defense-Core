// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./ThreatDetector.sol";
import "./CelestialPattern.sol";

interface IAdaptiveResponder {
    function respondToThreat(bytes32 componentId, uint256 sensorData) external returns (uint256 adaptedScore, bytes32 defensePattern);
}

contract AdaptiveResponder is IAdaptiveResponder {
    ThreatDetector public immutable detector;
    CelestialPattern public immutable celestialPattern;
    address public admin;
    
    mapping(bytes32 => uint256) public componentAdaptationLevel;
    mapping(bytes32 => bytes32) public activeDefenses;
    mapping(address => bool) public authorizedCallers;
    
    uint256 public constant MAX_ADAPTATION_BONUS = 50;
    uint256 public constant FLEET_KNOWLEDGE_MULTIPLIER = 10;
    
    event ResponseAdapted(bytes32 indexed componentId, bytes32 indexed attackId, uint256 adaptedScore, bytes32 defensePattern);
    event DefenseActivated(bytes32 indexed componentId, bytes32 defensePattern);
    
    modifier onlyAuthorized() {
        require(authorizedCallers[msg.sender] || msg.sender == admin, "Unauthorized");
        _;
    }
    
    constructor(address _detectorAddress, address _celestialPatternAddress) {
        detector = ThreatDetector(_detectorAddress);
        celestialPattern = CelestialPattern(_celestialPatternAddress);
        admin = msg.sender;
        authorizedCallers[msg.sender] = true;
    }
    
    function respondToThreat(bytes32 componentId, uint256 sensorData) 
        external 
        override 
        onlyAuthorized 
        returns (uint256 adaptedScore, bytes32 defensePattern) 
    {
        (bytes32 attackId, uint256 riskScore) = detector.detectThreat(componentId, sensorData);
        
        defensePattern = keccak256(abi.encodePacked(attackId, componentId, block.number));
        
        componentAdaptationLevel[componentId] = componentAdaptationLevel[componentId] + 1;
        uint256 adaptationBonus = componentAdaptationLevel[componentId] > MAX_ADAPTATION_BONUS 
            ? MAX_ADAPTATION_BONUS 
            : componentAdaptationLevel[componentId];
        
        adaptedScore = riskScore + adaptationBonus;
        activeDefenses[componentId] = defensePattern;
        
        emit ResponseAdapted(componentId, attackId, adaptedScore, defensePattern);
        emit DefenseActivated(componentId, defensePattern);
        
        return (adaptedScore, defensePattern);
    }
    
    function authorizeCaller(address caller) external {
        require(msg.sender == admin, "Only admin");
        authorizedCallers[caller] = true;
    }
    
    function getActiveDefense(bytes32 componentId) external view returns (bytes32) {
        return activeDefenses[componentId];
    }
}
