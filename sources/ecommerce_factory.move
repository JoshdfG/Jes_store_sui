    module ecommerce_factory::factory;
    use sui::tx_context:: sender;
    use sui::vec_map::{Self, VecMap};
    use std::string::{String};
    use jes_ecommerce::ecommerce;

    public struct StoreFactory has key {
        id: UID,
        stores: VecMap<ID, StoreInfo>,
    }

    public struct StoreInfo has store, drop {
        creator: address,
        store_name: String,
    }

    public fun get_creator_add(store:&StoreInfo):address{
       store.creator
    }

    public fun get_store_name(store:&StoreInfo):&String{
       &store.store_name
    }

    public fun get_factory_info(factory: &StoreFactory): &StoreFactory {
        factory
    }

    public entry fun create_initial_store(
        _platform_registry: &ecommerce::PlatformRegistry,
        store_name: String,
        image_cid: Option<String>,
        description: Option<String>,
        share_link: String,
        ctx: &mut TxContext
    ) {
        let factory_id = object::new(ctx);
        let mut factory = StoreFactory {
            id: factory_id,
            stores: vec_map::empty(),
        };

        let owner_address = sender(ctx);
        let store_id_value = ecommerce::create_store_internal(
            store_name, 
            image_cid, 
            description, 
            share_link, 
            ctx
        );

        let store_info = StoreInfo {
            creator: owner_address,
            store_name,
        };

        vec_map::insert(&mut factory.stores, store_id_value, store_info);
        transfer::share_object(factory);
    }

    //USED TO TEST IN THE CHILD CONTRACT TEST
    public entry fun create_store(
        factory: &mut StoreFactory,
        _platform_registry: &ecommerce::PlatformRegistry,
        store_name: String,
        image_cid: Option<String>,
        description: Option<String>,
        share_link: String,
        ctx: &mut TxContext
    ) {
        let owner_address = sender(ctx);
        let store_id_value = ecommerce::create_store_internal(
            store_name,
            image_cid,
            description,
            share_link,
            ctx
        );

        let store_info = StoreInfo {
            creator: owner_address,
            store_name,
        };
 
        vec_map::insert(&mut factory.stores, store_id_value, store_info);
    }

    public fun get_stores_by_creator(factory: &StoreFactory, creator: address): vector<ID> {
        let mut stores = vector::empty<ID>();
        let keys = vec_map::keys(&factory.stores);
        let mut i = 0;
        while (i < vector::length(&keys)) {
            let store_id = *vector::borrow(&keys, i);
            let store_info = vec_map::get(&factory.stores, &store_id);
            if (store_info.creator == creator) {
                vector::push_back(&mut stores, store_id);
            };
            i = i + 1;
        };
        stores
    }

    public fun get_all_stores(factory: &StoreFactory): vector<ID> {
        vec_map::keys(&factory.stores)
    }
