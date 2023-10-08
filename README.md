# Battle Pet Completionist
Battle Pet Completionist is a World of Warcraft addon designed to help you catch all the battle pets in the game.  
It is a completly new and clean implementation, without any code from the PetTracker add, which it aims to replace, since it has been claiming to be open source. (You get the license, but all the freedoms of the license is removed, so you get nothing)  
This addon is 100% GPL-3 licensed, and will stay that way.

## Features
* Displays the locations of all pets.
* Filter the list of pets shown (in the options dialog)
* Updates the tooltip for pets in the auction house (and pet cages in general), to show the source of the pet.
* Create TomTom waypoints by shift clicking a map pin.
* Work together with your party to capture pets (see Teamwork below).

The aim of the addon is to keep things simple, which is why there is no integration with the pet battles themselves - if you want help with that, please look at the [Pokemon Trainer NG](https://www.curseforge.com/wow/addons/pokemon-trainer-ng) addon.

## Teamwork
When both you and other players in your party have this addon installed (along with TomTom), you can use the "Help a Friend" feature.
When anyone in your party starts a pet battle, the following happends:
* Check if any uncollected pets are found - if so, notify the player and stop.
* If no uncollected pets are found, check if other players in your party is missing any of them.
* If someone is missing one (or more), ask the player if they want to notify the other player.
* If they do, the other player gets a popup, telling them who and which pets.
* If they accept the offer, a TomTom waypoint is created, and the other player is notified that the offer is accepted.
* If the offer is declined, the other player is notified as well.

## Legality of this addon
This addon looks and feels a lot like the old, non-open source PetTracker addon.  
The ideas behind this addon is based on that addon, but the code is a completely new implementation, with no code taken from PetTracker (which is needed, since the author of PetTracker doesn't like people using his work).  
This also means, that if you submit a pull request with changes, please make sure you are allowed to submit those changes.