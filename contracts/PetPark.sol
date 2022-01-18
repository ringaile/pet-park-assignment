//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "hardhat/console.sol";


contract PetPark {

    address public owner;

    enum Animal{ 
        None,
        Fish, 
        Cat, 
        Dog,
        Rabbit,
        Parrot 
    }

    enum Gender{
        Male,
        Female
    }

    mapping(Animal => uint) animals;
    mapping(address => bool) borrowed;

    mapping(address => bool) saved;
    mapping(address => Gender) genders;
    mapping(address => uint) ages;
    mapping(address => Animal) borrowedAnimals;

    event Added(Animal, uint256);
    event Borrowed(Animal);
    event Returned(Animal);

    modifier onlyOwner(){
        require(msg.sender == owner, "Not an owner");
        _;
    }

    constructor(){
        owner = msg.sender;
    }

    function add(Animal _animal, uint256 _count) public onlyOwner{
        require(_animal == Animal.Cat || _animal == Animal.Dog || _animal == Animal.Fish || _animal == Animal.Parrot || _animal == Animal.Rabbit, "Invalid animal");
        animals[_animal] += _count;
        emit Added(_animal, _count);
    }

    function borrow(uint _age, Gender _gender, Animal _animal) public {
        require(_age > 0, "Invalid Age");
        require(_animal == Animal.Cat || _animal == Animal.Dog || _animal == Animal.Fish || _animal == Animal.Parrot || _animal == Animal.Rabbit, "Invalid animal type");
        require(animals[_animal] > 0, "Selected animal not available");

        if (saved[msg.sender]) {
            require(ages[msg.sender] == _age, "Invalid Age");
            require(genders[msg.sender] == _gender, "Invalid Gender");
        }

        require(!borrowed[msg.sender], "Already adopted a pet");

        if (_gender == Gender.Male) {
            require(_animal == Animal.Dog || _animal == Animal.Fish, "Invalid animal for men");
        }
        if (_gender == Gender.Female && _age < 40) {
            require(_animal != Animal.Cat, "Invalid animal for women under 40");
        }

        saved[msg.sender] = true;
        ages[msg.sender] = _age;
        genders[msg.sender] = _gender;
        borrowed[msg.sender] = true;
        borrowedAnimals[msg.sender] = _animal;
        animals[_animal]--;
        emit Borrowed(_animal);
    }

    function animalCounts(Animal _animal) public view returns (uint256) {
        return animals[_animal];
    }

    function giveBackAnimal() public {
        require(borrowed[msg.sender], "No borrowed pets");
        borrowed[msg.sender] = true;
        animals[borrowedAnimals[msg.sender]]++;
        emit Returned(borrowedAnimals[msg.sender]);
    }

}