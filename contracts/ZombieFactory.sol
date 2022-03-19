// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

contract ZombieFactory {
  uint dnaDigits = 16;
  uint dnaModulus = 10 ** dnaDigits;

  event NewZombie(uint zombieId, string name, uint dna);

  struct Zombie {
    string name;
    uint dna;
  }

  Zombie[] public zombies;

  mapping(uint => address) public zombieToOwner;
  mapping(address => uint) public ownerToZombieCount;
  
  function _createZombie(string memory _name, uint _dna) private {
    zombies.push(Zombie(_name, _dna));
    uint id = zombies.length - 1;
    zombieToOwner[id] = msg.sender;
    ownerToZombieCount[msg.sender]++;
    emit NewZombie(id, _name, _dna);
  }

  function _generateRandomDna(string memory _str) private view returns (uint) {
    uint rand = uint(keccak256(abi.encodePacked(_str)));

    return rand % dnaModulus;
  }

  function createRandomZombie(string memory _name) public {
    require(ownerToZombieCount[msg.sender] == 0);
    uint randDna = _generateRandomDna(_name);
    _createZombie(_name, randDna);
  }

}