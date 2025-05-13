    #[test_only]
    module ecommerce_factory::factory_tests;
    use ecommerce_factory::factory::{
        StoreFactory,
        create_initial_store,
        create_store,
        get_stores_by_creator,
        get_all_stores,
       
    };
    use jes_ecommerce::ecommerce::{
        PlatformRegistry,
        Store,
        init_platform_registry,
        get_owner_address
    };
    use sui::test_scenario::{Self, Scenario};
    use std::string;


    const SELLER: address = @0xA;
    const OTHER: address = @0xC;

    fun init_test_scenario(): Scenario {
        test_scenario::begin(SELLER)
    }

#[test]
fun test_create_initial_store() {
    let mut scenario = init_test_scenario();
    test_scenario::next_tx(&mut scenario, SELLER);
    {
        let ctx = test_scenario::ctx(&mut scenario);
        init_platform_registry(ctx);
    };
    test_scenario::next_tx(&mut scenario, SELLER);
    {
        let registry = test_scenario::take_shared<PlatformRegistry>(&scenario);
        let ctx = test_scenario::ctx(&mut scenario);
        create_initial_store(
            &registry,
            string::utf8(b"Test Store"),
            option::none(),
            option::none(),
            string::utf8(b"test.com"),
            ctx,
        );
        test_scenario::return_shared(registry);
    };
    test_scenario::next_tx(&mut scenario, SELLER);
    {
        let factory = test_scenario::take_shared<StoreFactory>(&scenario);
        let store_ids = get_all_stores(&factory);
        assert!(vector::length(&store_ids) == 1, 0);
        let store = test_scenario::take_shared_by_id<Store>(&scenario, *vector::borrow(&store_ids, 0));
        assert!(get_owner_address(&store) == SELLER, 0);
        
        // Get StoreInfo through your module's public functions
        test_scenario::return_shared(factory);
        test_scenario::return_shared(store);
    };
    test_scenario::end(scenario);
}

#[test]
fun test_create_multiple_stores() {
    let mut scenario = init_test_scenario();
    test_scenario::next_tx(&mut scenario, SELLER);
    {
        let ctx = test_scenario::ctx(&mut scenario);
        init_platform_registry(ctx);
    };
    test_scenario::next_tx(&mut scenario, SELLER);
    {
        let registry = test_scenario::take_shared<PlatformRegistry>(&scenario);
        let ctx = test_scenario::ctx(&mut scenario);
        create_initial_store(
            &registry,
            string::utf8(b"First Store"),
            option::none(),
            option::none(),
            string::utf8(b"first.com"),
            ctx,
        );
        test_scenario::return_shared(registry);
    };
    test_scenario::next_tx(&mut scenario, SELLER);
    {
        let registry = test_scenario::take_shared<PlatformRegistry>(&scenario);
        let mut factory = test_scenario::take_shared<StoreFactory>(&scenario);
        let ctx = test_scenario::ctx(&mut scenario);
        create_store(
            &mut factory,
            &registry,
            string::utf8(b"Second Store"),
            option::none(),
            option::none(),
            string::utf8(b"second.com"),
            ctx,
        );
        test_scenario::return_shared(registry);
        test_scenario::return_shared(factory);
    };
    test_scenario::next_tx(&mut scenario, SELLER);
    {
        let factory = test_scenario::take_shared<StoreFactory>(&scenario);
        let store_ids = get_all_stores(&factory);
        assert!(vector::length(&store_ids) == 2, 0);
        let store1 = test_scenario::take_shared_by_id<Store>(&scenario, *vector::borrow(&store_ids, 0));
        let store2 = test_scenario::take_shared_by_id<Store>(&scenario, *vector::borrow(&store_ids, 1));
        assert!(get_owner_address(&store1) == SELLER, 0);
        assert!(get_owner_address(&store2) == SELLER, 0);
        
        // assert!(factory::get_store_name(&store1) == string::utf8(b"First Store"), 0);
        // assert!(factory::get_store_name(&store2) == string::utf8(b"Second Store"), 0);
        
        test_scenario::return_shared(factory);
        test_scenario::return_shared(store1);
        test_scenario::return_shared(store2);
    };
    test_scenario::end(scenario);
}

    #[test]
    fun test_get_stores_by_creator() {
        let mut scenario = init_test_scenario();
        test_scenario::next_tx(&mut scenario, SELLER);
        {
            let ctx = test_scenario::ctx(&mut scenario);
            init_platform_registry(ctx);
        };
        test_scenario::next_tx(&mut scenario, SELLER);
        {
            let registry = test_scenario::take_shared<PlatformRegistry>(&scenario);
            let ctx = test_scenario::ctx(&mut scenario);
            create_initial_store(
                &registry,
                string::utf8(b"Test Store"),
                option::none(),
                option::none(),
                string::utf8(b"test.com"),
                ctx,
            );
            test_scenario::return_shared(registry);
        };
        test_scenario::next_tx(&mut scenario, SELLER);
        {
            let factory = test_scenario::take_shared<StoreFactory>(&scenario);
            let store_ids = get_stores_by_creator(&factory, SELLER);
            assert!(vector::length(&store_ids) == 1, 0);
            let store = test_scenario::take_shared_by_id<Store>(&scenario, *vector::borrow(&store_ids, 0));
            assert!(get_owner_address(&store) == SELLER, 0);
            test_scenario::return_shared(factory);
            test_scenario::return_shared(store);
        };
        test_scenario::end(scenario);
    }

    #[test]
    fun test_get_stores_by_non_creator() {
        let mut scenario = init_test_scenario();
        test_scenario::next_tx(&mut scenario, SELLER);
        {
            let ctx = test_scenario::ctx(&mut scenario);
            init_platform_registry(ctx);
        };
        test_scenario::next_tx(&mut scenario, SELLER);
        {
            let registry = test_scenario::take_shared<PlatformRegistry>(&scenario);
            let ctx = test_scenario::ctx(&mut scenario);
            create_initial_store(
                &registry,
                string::utf8(b"Test Store"),
                option::none(),
                option::none(),
                string::utf8(b"test.com"),
                ctx,
            );
            test_scenario::return_shared(registry);
        };
        test_scenario::next_tx(&mut scenario, OTHER);
        {
            let factory = test_scenario::take_shared<StoreFactory>(&scenario);
            let store_ids = get_stores_by_creator(&factory, OTHER);
            assert!(vector::length(&store_ids) == 0, 0);
            test_scenario::return_shared(factory);
        };
        test_scenario::end(scenario);
    }

    #[test]
    fun test_get_all_stores() {
        let mut scenario = init_test_scenario();
        test_scenario::next_tx(&mut scenario, SELLER);
        {
            let ctx = test_scenario::ctx(&mut scenario);
            init_platform_registry(ctx);
        };
        test_scenario::next_tx(&mut scenario, SELLER);
        {
            let registry = test_scenario::take_shared<PlatformRegistry>(&scenario);
            let ctx = test_scenario::ctx(&mut scenario);
            create_initial_store(
                &registry,
                string::utf8(b"First Store"),
                option::none(),
                option::none(),
                string::utf8(b"first.com"),
                ctx,
            );
            test_scenario::return_shared(registry);
        };
        test_scenario::next_tx(&mut scenario, SELLER);
        {
            let registry = test_scenario::take_shared<PlatformRegistry>(&scenario);
            let mut factory = test_scenario::take_shared<StoreFactory>(&scenario);
            let ctx = test_scenario::ctx(&mut scenario);
            create_store(
                &mut factory,
                &registry,
                string::utf8(b"Second Store"),
                option::none(),
                option::none(),
                string::utf8(b"second.com"),
                ctx,
            );
            test_scenario::return_shared(registry);
            test_scenario::return_shared(factory);
        };
        test_scenario::next_tx(&mut scenario, SELLER);
        {
            let factory = test_scenario::take_shared<StoreFactory>(&scenario);
            let store_ids = get_all_stores(&factory);
            assert!(vector::length(&store_ids) == 2, 0);
            test_scenario::return_shared(factory);
        };
        test_scenario::end(scenario);
    }

