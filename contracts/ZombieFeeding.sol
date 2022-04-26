// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import './ZombieFactory.sol';

abstract contract KittyInterface {
  function getKitty(uint256 _id) virtual external view returns (
    bool isGestating,
    bool isReady,
    uint256 cooldownIndex,
    uint256 nextActionAt,
    uint256 siringWithId,
    uint256 birthTime,
    uint256 matronId,
    uint256 sireId,
    uint256 generation,
    uint256 genes
  );
}

contract ZombieFeeding is ZombieFactory{

  KittyInterface kittyContract;

  function setKittyContractAddress(address _address) external onlyOwner{
   kittyContract = KittyInterface(_address);
  }

    function _triggerCooldown(Zombie storage _zombie) internal {
    _zombie.readyTime = uint32(block.timestamp + cooldownTime);
  }

  function _isReady(Zombie storage _zombie) internal view returns (bool) {
      return (_zombie.readyTime <= block.timestamp);
  }


  function feedAndMultiply(uint _zombieId, uint _targetDna, string memory _species) internal {
    require(zombieToOwner[_zombieId] == msg.sender);
    
    Zombie storage myZombie = zombies[_zombieId];
    // check cooldown
    require(_isReady(myZombie));
  
   _targetDna = _targetDna % dnaModulus;
    uint newDna = (myZombie.dna + _targetDna) / 2;

    if(keccak256(abi.encodePacked(_species)) == keccak256(abi.encodePacked("kitty"))){
       newDna = newDna - newDna % 100 + 99;
    }

    _createZombie("name", newDna);

    _triggerCooldown(myZombie);
  }

  function feedOnKitty(uint _zombieId, uint _kittyId) public {
    uint kittyDna;
     (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId);
    feedAndMultiply(_zombieId, kittyDna, "kitty");
  }

}