#[test_only]
module jes_ecommerce::jes_ecommerce_tests;
use jes_ecommerce::ecommerce;
    use jes_ecommerce::ecommerce::{
        PlatformRegistry,
        TestUserRegistry,
        Store,
        Cart,
        register_user,
        init_platform_registry,
        test_register_user,
        add_product,
        create_cart,
        get_user_id,
        get_store_id,
        get_owner_address,
        new_test_user_registry,
        share_test_user_registry,
    };
    use ecommerce_factory::factory::{
        StoreFactory,
        create_initial_store,
        get_all_stores
    };
    use sui::test_scenario::{Self, Scenario};
   use std::string;

    const SELLER: address = @0xA;
    const BUYER: address = @0xB;

    fun init_test_scenario(): Scenario {
        test_scenario::begin(SELLER)
    }


    #[test]
    fun test_init() {
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
            test_scenario::return_shared(factory);
            test_scenario::return_shared(store);
        };
        test_scenario::end(scenario);
    }

    #[test]
    fun test_register() {
        let mut scenario = init_test_scenario();
        test_scenario::next_tx(&mut scenario, SELLER);
        {
            let ctx = test_scenario::ctx(&mut scenario);
            init_platform_registry(ctx);
        };
        test_scenario::next_tx(&mut scenario, BUYER);
        {
            let mut registry = test_scenario::take_shared<PlatformRegistry>(&scenario);
            let ctx = test_scenario::ctx(&mut scenario);
            register_user(
                &mut registry,
                BUYER,
                option::some(string::utf8(b"Buyer")),
                option::none(),
                option::none(),
                option::none(),
                ctx,
            );
            test_scenario::return_shared(registry);
        };
        test_scenario::next_tx(&mut scenario, BUYER);
        {
            let registry = test_scenario::take_shared<PlatformRegistry>(&scenario);
            let user_id = get_user_id(&registry, BUYER);
            assert!(option::is_some(&user_id), 0);
            test_scenario::return_shared(registry);
        };
        test_scenario::end(scenario);
    }

    #[test]
    fun test_create_store() {
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
            assert!(get_store_id(&store) == *vector::borrow(&store_ids, 0), 0);
            test_scenario::return_shared(factory);
            test_scenario::return_shared(store);
        };
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = jes_ecommerce::ecommerce::EUserAlreadyRegistered)]
    fun test_register_user_twice_fails() {
        let mut scenario = init_test_scenario();

        test_scenario::next_tx(&mut scenario, SELLER);
        {
            let ctx = test_scenario::ctx(&mut scenario);
            let registry = new_test_user_registry(ctx);
            share_test_user_registry(registry);
        };
        
        test_scenario::next_tx(&mut scenario, BUYER);
        {
            let mut registry = test_scenario::take_shared<TestUserRegistry>(&scenario);
            let ctx = test_scenario::ctx(&mut scenario);
            test_register_user(
                &mut registry,
                BUYER,
                option::some(string::utf8(b"Buyer")),
                option::none(),
                option::none(),
                option::none(),
                ctx,
            );
            test_scenario::return_shared(registry);
        };
        
        test_scenario::next_tx(&mut scenario, BUYER);
        {
            let mut registry = test_scenario::take_shared<TestUserRegistry>(&scenario);
            let ctx = test_scenario::ctx(&mut scenario);
            test_register_user(
                &mut registry,
                BUYER,
                option::some(string::utf8(b"Buyer")),
                option::none(),
                option::none(),
                option::none(),
                ctx,
            );
            test_scenario::return_shared(registry);
        };
        
        test_scenario::end(scenario);
    }

    #[test]
    fun test_platform_flow() {
        let mut scenario = init_test_scenario();
        test_scenario::next_tx(&mut scenario, SELLER);
        {
            let ctx = test_scenario::ctx(&mut scenario);
            init_platform_registry(ctx);
        };
        test_scenario::next_tx(&mut scenario, BUYER);
        {
            let mut registry = test_scenario::take_shared<PlatformRegistry>(&scenario);
            let ctx = test_scenario::ctx(&mut scenario);
            register_user(
                &mut registry,
                BUYER,
                option::some(string::utf8(b"Buyer")),
                option::none(),
                option::none(),
                option::none(),
                ctx,
            );
            test_scenario::return_shared(registry);
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
                string::utf8(b"firststore.com"),
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
                string::utf8(b"secondstore.com"),
                ctx,
            );
            test_scenario::return_shared(registry);
            test_scenario::return_shared(factory);
        };
        test_scenario::next_tx(&mut scenario, BUYER);
        {
            let registry = test_scenario::take_shared<PlatformRegistry>(&scenario);
            let factory = test_scenario::take_shared<StoreFactory>(&scenario);
            let store_ids = get_all_stores(&factory);
            assert!(vector::length(&store_ids) == 2, 0);
            let user_id = get_user_id(&registry, BUYER);
            assert!(option::is_some(&user_id), 0);
            test_scenario::return_shared(registry);
            test_scenario::return_shared(factory);
        };
        test_scenario::end(scenario);
    }
 
    #[test]
    fun test_create_cart_unregistered() {
        let mut scenario = init_test_scenario();
        test_scenario::next_tx(&mut scenario, SELLER);
        {
            let ctx = test_scenario::ctx(&mut scenario);
            init_platform_registry(ctx);
        };
        test_scenario::next_tx(&mut scenario, BUYER);
        {
            let ctx = test_scenario::ctx(&mut scenario);
            create_cart(ctx);
        };
        test_scenario::next_tx(&mut scenario, BUYER);
        {
            let cart = test_scenario::take_shared<Cart>(&scenario);
            let cart_ref = &cart;
            assert!(ecommerce::get_cart_add(cart_ref) == BUYER, 0);
            test_scenario::return_shared(cart);
        };
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = jes_ecommerce::ecommerce::ENotOwner)]
    fun test_add_product_non_owner_fails() {
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
        test_scenario::next_tx(&mut scenario, BUYER);
        {
            let factory = test_scenario::take_shared<StoreFactory>(&scenario);
            let store_ids = get_all_stores(&factory);
            let store = test_scenario::take_shared_by_id<Store>(&scenario, *vector::borrow(&store_ids, 0));
            let ctx = test_scenario::ctx(&mut scenario);
            add_product(
                &store,
                string::utf8(b"Product"),
                option::none(),
                option::none(),
                100,
                10,
                ctx,
            );
            test_scenario::return_shared(factory);
            test_scenario::return_shared(store);
        };
        test_scenario::end(scenario);
    }

