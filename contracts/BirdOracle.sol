pragma solidity >=0.4.21 <0.6.0;

 // SPDX-License-Identifier: MIT
/**
Bird On-chain Oracle to confirm rating with 2+ consensus before update using the off-chain API https://www.bird.money/docs
*/

contract BirdOracle {
  BirdRequest[] onChainRequests; //keep track of list of on-chain requests
  uint minConsensus = 2; //minimum number of consensus before confirmation 
  uint birdNest = 3; // bird consensus count
  uint trackId = 0; //increament id's

    /**
   * Bird Standard API Request
   * id: "1"
   * url: "https://www.bird.money/analytics/address/ethaddress"
   * key: "bird_rating"
   * value: "0.4"
   * response: response from off-chain oracles 
   * nest: approved off-chain oracles nest/addresses and keep track of vote (1=not voted, 2=voted)
   */
  struct BirdRequest {
    uint id;   
    string url; 
    string key; 
    string value;  
    bool resolved;
    mapping(uint => string) response;
    mapping(address => uint) nest; 
  }
  
    /**
   * Bird Standard API Request
   * Off-Chain-Request from outside the blockchain 
   */
  event OffChainRequest (
    uint id,
    string url,
    string key
  );

    /**
   * To call when there is consensus on final result
   */
   
  event UpdatedRequest (
    uint id,
    string url,
    string key,
    string value
  );

  // container for the ratings
  mapping (string => string) ratings;

  function newChainRequest (
    string memory _url,
    string memory _key
  )
  public   
  {
    uint lenght = onChainRequests.push(BirdRequest(trackId, _url, _key, "", false));
    BirdRequest storage r = onChainRequests[lenght-1];

    /**
   * trusted oracles in bird nest
   */
    address trustedBird1 = address(0x35fA8692EB10F87D17Cd27fB5488598D33B023E5);
    address trustedBird2 = address(0x58Fd79D34Edc6362f92c6799eE46945113A6EA91);
    address trustedBird3 = address(0x0e4338DFEdA53Bc35467a09Da483410664d34e88);
    
    /**
   * track votes
   */
    r.nest[trustedBird1] = 1;
    r.nest[trustedBird2] = 1;
    r.nest[trustedBird3] = 1;

    /**
   * Off-Chain event trigger
   */
    emit OffChainRequest (
      trackId,
      _url,
      _key
    );

    /**
   * Off-Chain event trigger
   */
    trackId++;
  }

  //called by the oracle to record its answer
    /**
   * Off-Chain oracle to update its consensus answer
   */
  function updatedChainRequest (
    uint _id,
    string memory _valueResponse
  ) public {

    BirdRequest storage trackRequest = onChainRequests[_id];

    if (trackRequest.resolved)
      return;

    /**
   * To confirm an address/oracle is part of the trusted nest and has not voted
   */
    if(trackRequest.nest[address(msg.sender)] == 1){
        
        /**
       * change vote value to = 2 from 1
       */
      trackRequest.nest[msg.sender] = 2;
      
        /**
       * Loop through responses for empty position, save the response
       * TODO: refactor
       */
      uint tmpI = 0;
      bool found = false;
      while(!found) {
          
        if(bytes(trackRequest.response[tmpI]).length == 0){
          found = true;
          trackRequest.response[tmpI] = _valueResponse;
        }
        tmpI++;
      }

      uint currentConsensusCount = 0;
      
        /**
       * Loop through list and check if min consensus has been reached
       */
      
      for(uint i = 0; i < birdNest; i++){
        bytes memory a = bytes(trackRequest.response[i]);
        bytes memory b = bytes(_valueResponse);

        if(keccak256(a) == keccak256(b)){
          currentConsensusCount++;
          if(currentConsensusCount >= minConsensus){
            trackRequest.value = _valueResponse;

            trackRequest.resolved = true;

            // Save value and user information into the bird rating container
            ratings[trackRequest.url] = trackRequest.value;
            

            emit UpdatedRequest (
              trackRequest.id,
              trackRequest.url,
              trackRequest.key,
              trackRequest.value
            );
          }
        }
      }
    }
  }

    /**
   * access to saved ratings after Oracle consensus
   */
  function getRating(string memory _url) public view returns (string memory) {
        return ratings[_url];
  }

}