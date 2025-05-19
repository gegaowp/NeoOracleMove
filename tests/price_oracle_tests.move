// neo_oracle_move/tests/price_oracle_tests.move
#[test_only]
module neo_oracle_move::price_oracle_tests {
    use neo_oracle_move::price_oracle::{PriceObject, create_price_object, update_price, symbol, price, timestamp_ms, decimals};
    use sui::test_scenario;
    use std::string;

    const ORACLE_ADMIN: address = @0xA1; // Example admin address for tests

    // Helper to initialize a scenario and create the initial object in its own transaction
    fun initial_object_creation_tx(test_scenario_ref: &mut test_scenario::Scenario) {
        test_scenario::next_tx(test_scenario_ref, ORACLE_ADMIN);
        let symbol_vec = b"BTC/USD";
        let initial_price = 50000_00000000; // e.g., $50,000 with 8 decimals
        let initial_ts = 1678886400000; // Example timestamp
        let dec = 8u8;

        create_price_object(symbol_vec, initial_price, initial_ts, dec, test_scenario::ctx(test_scenario_ref));
        // Object is now created and transferred to ORACLE_ADMIN. Effects will be visible in the next transaction.
    }

    #[test]
    fun test_create_and_getters() {
        let mut scenario = test_scenario::begin(ORACLE_ADMIN);
        initial_object_creation_tx(&mut scenario);

        // Start a new transaction to interact with the created object
        test_scenario::next_tx(&mut scenario, ORACLE_ADMIN);
        let price_obj_taken = test_scenario::take_from_sender<PriceObject>(&scenario);

        assert!(string::utf8(b"BTC/USD") == symbol(&price_obj_taken), 0);
        assert!(50000_00000000 == price(&price_obj_taken), 1);
        assert!(1678886400000 == timestamp_ms(&price_obj_taken), 2);
        assert!(8u8 == decimals(&price_obj_taken), 3);

        test_scenario::return_to_sender(&scenario, price_obj_taken);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_update_price_success() {
        let mut scenario = test_scenario::begin(ORACLE_ADMIN);
        initial_object_creation_tx(&mut scenario);
        
        // Start a new transaction to take and update the object
        test_scenario::next_tx(&mut scenario, ORACLE_ADMIN);
        let mut price_object_mut_ref = test_scenario::take_from_sender<PriceObject>(&scenario);
        
        let new_p = 60000_00000000;
        let new_ts = 1678887400000;
        update_price(&mut price_object_mut_ref, new_p, new_ts);
        
        assert!(new_p == price(&price_object_mut_ref), 10);
        assert!(new_ts == timestamp_ms(&price_object_mut_ref), 11);
        assert!(string::utf8(b"BTC/USD") == symbol(&price_object_mut_ref), 12);
        assert!(8u8 == decimals(&price_object_mut_ref), 13);

        test_scenario::return_to_sender(&scenario, price_object_mut_ref);
        test_scenario::end(scenario);
    }

    // We could add a test for attempting to update by a non-owner if our update_price
    // function took a capability or if the object was shared. However, with `&mut PriceObject`
    // owned by ORACLE_ADMIN, the framework already prevents non-owners from getting such a mutable reference
    // in a real transaction. Test framework might allow more flexibility but the core logic relies
    // on ownership for `&mut` access to entry functions.
} 