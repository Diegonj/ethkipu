// SPDX-License-Identifier: GPL-3.0


pragma solidity >=0.8.2 <0.9.0;


contract auction {
    
    //----------------------VAR DECLARATION----------------------// 
    struct Offer {
        address user;
        uint256 amount;
    }

    struct EndingMessage {
        string message;
    }

    string messageToClaimers = "La subasta aun esta en curso, no podes retirar tu oferta";
    string messageToManager = "La subasta sigue en curso, todavia no se puede finalizar.";

    Offer[] offersRecord;
    uint public expirationDate; 
    uint validGapBetweenOffers;
    uint256 public maxOffer;
    uint minimumOffer;
    address auctionManager;

    mapping (address=>uint[]) public offers;
    mapping (address=>uint) public balances;
    mapping (address=>uint256) public claimedAmount;
    mapping (address=>bool) public userClaimed;


    event offerMade(address who, uint256 value); 
    event auctionFinished(EndingMessage message);

    //---------------------------------------------------------//


    //----------------------CONSTRUCTOR------------------------//
    constructor(uint _duration, uint _gapPercentage) {

        expirationDate = block.timestamp + _duration;
        validGapBetweenOffers = _gapPercentage;
        minimumOffer = 1;
        auctionManager = msg.sender;

     }



    //----------------------FUNCTIONS---------------------------//

    function offer() external payable auctionIsAvailable() offerIsValid(){
        
        balances[msg.sender] = msg.sender.balance;
        require(balances[msg.sender] >= msg.value,"El ofertante no tiene los fondos suficientes para la oferta que se quiere hacer.");
        offers[msg.sender].push(msg.value);
        //balances[msg.sender] -= msg.value; --> la primera línea de la función ya reduce el value al sender, porque el payable se encargó de descontarlo.
        offersRecord.push(Offer({user: msg.sender, amount: msg.value}));
        maxOffer = msg.value;
        emit offerMade(msg.sender,msg.value);

        if (block.timestamp >= expirationDate - 10 minutes){
            expirationDate += 10 minutes;
        }
        
    } 




    function sumOffersOfAddress () public view returns (uint256){
        
        uint256 result=0;
        uint256[] memory valueSum = offers[msg.sender];

        for (uint i = 0; i < valueSum.length; i++) {
            result += valueSum[i];
        }

        return result;
    } 
    



    function showWinner() external view returns (Offer memory) {

        uint256 localMaxOffer = 0;
        uint indexWinner = 0;
        Offer memory _winner;

        for (uint i = 0; i < offersRecord.length; i++) {
            if(localMaxOffer < offersRecord[i].amount){
               indexWinner = i;
            }    
        }

        _winner = offersRecord[indexWinner];       
        return _winner;
    }




    function closeAuction() external {

        require (msg.sender == auctionManager, "La subasta solo puede ser cerrada por el manager.");
        require (block.timestamp >= expirationDate,"La subasta sigue en curso, todavia no se puede finalizar.");
        emit auctionFinished(EndingMessage("Se acaba de cerrar la subasta formalmente."));

    } 




    function claimMyOffers() external hasExistingOffer(){

        require(block.timestamp >= expirationDate,"La subasta sigue en curso, todavia no podes reclamar tu oferta.");
        require(address(this).balance > 0, "No hay saldo disponible para devolver. Si tenes inconvenientes con la devolucion de tu oferta, por favor contactanos.");
        require(userClaimed[msg.sender] == false, "Ya reclamaste tu subasta y te la pagamos, no podes recibir el dinero nuevamente.");
        
        uint256 valueToClaim = sumOffersOfAddress() - claimedAmount[msg.sender];

        if (msg.sender == this.showWinner().user) {
            valueToClaim = valueToClaim - maxOffer;
        }

        valueToClaim = valueToClaim*98/100;

        balances[msg.sender] += valueToClaim;

        (bool result,) = msg.sender.call{value: valueToClaim}("");
        require(result);

        userClaimed[msg.sender] = true;

    }




    function partialClaim() external hasExistingOffer(){

        require(block.timestamp <= expirationDate,"La subasta termino, anda a reclamar tu saldo final.");
        require(address(this).balance > 0, "No hay saldo disponible para devolver. Si tenes inconvenientes con la devolucion de tu oferta, por favor contactanos.");
        
        uint256 valueToClaim = sumOffersOfAddress() - claimedAmount[msg.sender];

        if (msg.sender == this.showWinner().user) {
            valueToClaim = valueToClaim - maxOffer;
        }

        claimedAmount[msg.sender] += valueToClaim;

        balances[msg.sender] += valueToClaim;

        (bool result,) = msg.sender.call{value: valueToClaim}("");
        require(result);


    } 


    


    //----------------------MODIFIERS---------------------------//
    modifier auctionIsAvailable() {
        require (block.timestamp <= expirationDate,"La subasta ha finalizado, no se puede realizar una nueva oferta. Gracias!");
        _;
    }


    modifier offerIsValid() {
        require(msg.value >= minimumOffer, "El valor de la oferta debe ser de al menos 1 Wei.");
        require(100 * msg.value >= maxOffer * (100 + validGapBetweenOffers),"La oferta no es valida, por favor revise las condiciones de la subasta y vuelve a intentarlo");
        _;
    }
    

    modifier hasExistingOffer() {
        require(offers[msg.sender].length> 0,"No hiciste ninguna oferta, no podes reclamar.");
        _;
    }

}