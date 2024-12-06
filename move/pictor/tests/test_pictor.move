#[test_only]
module pictor::pictor_tests;

use pictor::pictor::{Self, PICTOR};
use sui::coin::{Coin, TreasuryCap};
use sui::test_scenario::{Self, next_tx, ctx};

#[test]
fun mint_burn() {
    // Initialize a mock sender address
    let addr1 = @0xA;

    // Begins a multi transaction scenario with addr1 as the sender
    let mut scenario = test_scenario::begin(addr1);
    
    // Run the pictor coin module init function
    {
        pictor::test_init(ctx(&mut scenario))
    };

    // Mint a `Coin<PICTOR>` object
    next_tx(&mut scenario, addr1);
    {
        let mut treasurycap = test_scenario::take_from_sender<TreasuryCap<PICTOR>>(&scenario);
        pictor::mint(&mut treasurycap, 100, addr1, test_scenario::ctx(&mut scenario));
        test_scenario::return_to_address<TreasuryCap<PICTOR>>(addr1, treasurycap);
    };

    // Burn a `Coin<PICTOR>` object
    next_tx(&mut scenario, addr1);
    {
        let coin = test_scenario::take_from_sender<Coin<PICTOR>>(&scenario);
        let mut treasurycap = test_scenario::take_from_sender<TreasuryCap<PICTOR>>(&scenario);
        pictor::burn(&mut treasurycap, coin);
        test_scenario::return_to_address<TreasuryCap<PICTOR>>(addr1, treasurycap);
    };

    // Cleans up the scenario object
    test_scenario::end(scenario);
}
