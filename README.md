# ethkipu
Repositorio donde estarán todos los trabajos realizados en el curso 2025
=========================================================================

------------------------------------------------
------Auction Smart Contract (auction.sol)------
------------------------------------------------


OPORTUNIDADES DE MEJORA
El contrato, al ser el primero que hago, tiene varias oportunidades de mejora.

Algunas:
 - La lógica para extender el tiempo cuando quedan menos de 10 minutos a la subasta funciona bien, pero se puede mejorar.
 - En el cierre de la subasta se podria armar una logica para detectar qué saldo hay que devolverle a qué direcciones y hacerlo automáticamente con la función claim ya desarrollada o una adaptada teniendo en cuenta el consumo de gas
 - El consumo de gas en general supongo que es alto, se usan muchas estructuras para hacer cosas "parecidas". Falta aplicarle buenos patrones de diseño y buenas prácticas.
 - A veces hay código parecido en varias secciones, se podrían usar mejor los modificadores o aplicar funciones para evitar esto.


-------------------------------------------------



VARIABLES PRINCIPALES
=====================

Offer struct: Define una oferta con user (dirección) y amount (valor).

EndingMessage struct: Usado solo para mostrar mensajes al cerrar la subasta.

messageToClaimers, messageToManager: Mensajes estáticos.

offersRecord: Lista de todas las ofertas realizadas.

expirationDate: Fecha de cierre de la subasta.

validGapBetweenOffers: Porcentaje mínimo de diferencia entre ofertas.

maxOffer: Máxima oferta registrada.

minimumOffer: Valor mínimo de oferta (en Wei).

auctionManager: Dirección que administra la subasta.

offers: Mapping que almacena todas las ofertas por cada dirección.

balances: Balance asociado a cada dirección.

claimedAmount: Cantidad ya reclamada por cada usuario.

userClaimed: Indica si un usuario ya reclamó su saldo.




EVENTOS
=======

offerMade(address who, uint256 value): Emitido cuando se hace una oferta.

auctionFinished(EndingMessage message): Emitido al cerrar la subasta.


FUNCIONES
=========

offer()

Permite hacer una oferta siempre que:

   - La subasta esté abierta.

   - La oferta supere la máxima actual + el gap definido en el constructor.

   - La cuenta tenga saldo suficiente.

Extiende la subasta 10 minutos si la oferta entra en los últimos 10 minutos.



sumOffersOfAddress()

Suma todas las ofertas hechas por el msg.sender.



showWinner()

Devuelve la mejor oferta registrada.



closeAuction()

Permite al auctionManager cerrar formalmente la subasta.



claimMyOffers()

Permite reclamar el 98% del total ofertado menos la oferta ganadora (si corresponde). Solo se puede usar una vez, y solo si la subasta ha finalizado.



partialClaim()

Permite hacer un retiro parcial antes del cierre de la subasta, menos la oferta ganadora (en caso de que el que reclama sea el máximo oferente hasta el momento).



MODIFICADORES
=============

auctionIsAvailable: Verifica que la subasta no haya finalizado.

offerIsValid: Verifica que la oferta cumpla con el mínimo y con el gap definido.

hasExistingOffer: Verifica que el usuario haya realizado al menos una oferta.
