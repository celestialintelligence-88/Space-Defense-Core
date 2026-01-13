// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./AdaptiveResponder.sol";

contract ImmutableLogger {
    IAdaptiveResponder public immutable responder;
    address public immutable admin;
    
    struct DefenseLog {
        bytes32 componentId;
        uint256 sensorData;
        uint256 adaptedScore;
        bytes32 defensePattern;
        uint256 timestamp;
        address triggeredBy;
    }
    
    DefenseLog[] public logs;
    mapping(address => bool) public authorizedLoggers;
    
    event ActionLogged(
        bytes32 indexed componentId, 
        uint256 adaptedScore, 
        bytes32 defensePattern, 
        uint256 timestamp,
        address indexed triggeredBy
    );
    
    modifier onlyAuthorized() {
        require(authorizedLoggers[msg.sender] || msg.sender == admin, "Unauthorized logger");
        _;
    }
    
    constructor(address _responderAddress) {
        responder = IAdaptiveResponder(_responderAddress);
        admin = msg.sender;
        authorizedLoggers[msg.sender] = true;
    }
    
    function logDefenseAction(bytes32 componentId, uint256 sensorData) 
        external 
        onlyAuthorized 
    {
        (uint256 adaptedScore, bytes32 defensePattern) = responder.respondToThreat(componentId, sensorData);
        
        logs.push(DefenseLog({
            componentId: componentId,
            sensorData: sensorData,
            adaptedScore: adaptedScore,
            defensePattern: defensePattern,
            timestamp: block.timestamp,
            triggeredBy: msg.sender
        }));
        
        emit ActionLogged(componentId, adaptedScore, defensePattern, block.timestamp, msg.sender);
    }
    
    function getLogCount() external view returns (uint256) {
        return logs.length;
    }
    
    function getLatestLog() external view returns (DefenseLog memory) {
        require(logs.length > 0, "No logs available");
        return logs[logs.length - 1];
    }
    
    function getLogRange(uint256 start, uint256 end) 
        external 
        view 
        returns (DefenseLog[] memory) 
    {
        require(end > start && end <= logs.length, "Invalid range");
        uint256 length = end - start;
        DefenseLog[] memory range = new DefenseLog[](length);
        
        for (uint256 i = 0; i < length; i++) {
            range[i] = logs[start + i];
        }
        
        return range;
    }
    
    function authorizeLogger(address logger) external {
        require(msg.sender == admin, "Only admin");
        authorizedLoggers[logger] = true;
    }
}
