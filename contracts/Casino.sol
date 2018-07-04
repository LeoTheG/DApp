pragma solidity 0.4.24;

contract Casino {
    address public owner;
    uint256 public minimumBet;
    uint256 public totalBet;
    uint256 public numberOfBets;
    uint256 public maxAmountOfBets = 100;
    address[] public players;
    uint256 public numberGenerated;

    struct Player{
        uint256 amountBet;
        uint256 numberSelected;
    }

    // maps address & player to playerInfo
    mapping(address=>Player) public playerInfo;

    //function Casino(uint256 _minimumBet) public {
    constructor(uint256 _minimumBet) public {
        owner = msg.sender;
        if(_minimumBet != 0) minimumBet = _minimumBet;
    }

    function kill() public {
        if(msg.sender == owner) selfdestruct(owner);
    }

    // constant => doesn't cost any gas to run b/c it's returning
    // an already existing value from blockchain -- reading a value
    function checkPlayerExists(address player) public constant returns(bool){
        for(uint256 i = 0; i < players.length; i++){
            if(players[i]==player) return true;
        }
        return false;
    }

    function generateNumberWinner() public {
        numberGenerated = block.number % 10 + 1; // not secure
        distributePrizes(numberGenerated);
    }

    function distributePrizes(uint256 numberWinner) public {
        address[100] memory winners;
        uint256 count = 0;
        for(uint256 i=0; i<players.length; i++){
            address playerAddress = players[i];
            // add player to array of winners
            if(playerInfo[playerAddress].numberSelected == numberWinner){
                winners[count] = playerAddress;
                count++;
            }
            delete playerInfo[playerAddress]; //delete all the players
            totalBet = 0;
            numberOfBets = 0;
        }

        players.length = 0; // delete all the players

        // winnings split amongst winners
        uint256 winnerEtherAmount = totalBet / winners.length;

        for(uint256 j=0; j<count;j++){
            if(winners[j] != address(0)) winners[j].transfer(winnerEtherAmount);
        }
    }

    //To bet for a number between 1 and 10 inclusive
    // payable => function can receive either when executed
    // msg.sender & msg.value are defined by user when executing contract
    //sender = address, value = amount of ether paid when executing payable fxn
    function bet(uint256 numberSelected) public payable {
        // verify player hasn't played already
        require(!checkPlayerExists(msg.sender));
        require(numberSelected >=1 && numberSelected <=10);
        require(msg.value >= minimumBet);

        playerInfo[msg.sender].amountBet = msg.value;
        playerInfo[msg.sender].numberSelected = numberSelected;
        numberOfBets++;
        players.push(msg.sender);
        totalBet += msg.value;

        if(numberOfBets >= maxAmountOfBets) generateNumberWinner();
    }

    // fallback function, executed when sending ether to contract w/o
    // executing any function
    function() public payable{}
}
