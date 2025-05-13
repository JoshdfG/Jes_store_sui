    module jes_ecommerce::ecommerce; 
    use sui::tx_context:: sender;
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use sui::dynamic_object_field as dof;
    use sui::vec_map::{Self, VecMap};
    use std::string::{Self, String};

    const ENotOwner: u64 = 0;
    const EInsufficientStock: u64 = 1;
    const EEmptyCart: u64 = 2;
    const EInvalidStatus: u64 = 3;
    const EInvalidBuyer: u64 = 5;
    const EProductNotFound: u64 = 6;
    const EProductMismatch: u64 = 7;
    const EUserAlreadyRegistered: u64 = 8;
    const EUserNotRegistered: u64 = 9;

    public struct PlatformRegistry has key {
        id: UID,
        users: VecMap<address, ID>,
    }

    public entry fun init_platform_registry(ctx: &mut TxContext) {
        let registry_id = object::new(ctx);
        let registry = PlatformRegistry {
            id: registry_id,
            users: vec_map::empty(),
        };
        transfer::share_object(registry);
    }

    #[test_only]
    public struct TestUserRegistry has key {
        id: UID,
        users: VecMap<address, ID>,
    }

    #[test_only]
    public(package) fun new_test_user_registry(ctx: &mut TxContext): TestUserRegistry {
        let id = object::new(ctx);
        let users = vec_map::empty<address, ID>();
        TestUserRegistry {
            id,
            users
        }
    }

    #[test_only]
    public(package) fun share_test_user_registry(registry: TestUserRegistry) {
        transfer::share_object(registry);
    }

    #[test_only]
    public entry fun test_create_store_and_share(
        store_name: String,
        image_cid: Option<String>,
        description: Option<String>,
        share_link: String,
        ctx: &mut TxContext
    ) {
        let _id = create_store_internal(store_name, image_cid, description, share_link, ctx);
    }

    public struct Store has key, store {
        id: UID,
        store_name: String,
        image_cid: Option<String>,
        description: Option<String>,
        owner_address: address,
        share_link: String,
    }

    public struct Product has key, store {
        id: UID,
        store_id: ID,
        product_name: String,
        image_cid: Option<String>,
        description: Option<String>,
        price: u64,
        quantity: u64,
    }

    public struct User has key, store {
        id: UID,
        wallet_address: address,
        user_name: Option<String>,
        email: Option<String>,
        phone_number: Option<String>,
        house_address: Option<String>,
    }

    public struct Cart has key, store {
        id: UID,
        user_address: address,
    }

    public struct CartItem has key, store {
        id: UID,
        cart_id: ID,
        product_id: ID,
        quantity: u64,
    }

    public struct Order has key, store {
        id: UID,
        order_id: String,
        store_id: ID,
        product_id: ID,
        user_id: ID,
        buyer_address: address,
        seller_address: address,
        amount: u64,
        status: String,
        payment_status: String,
        transaction_hash: Option<String>,
    }

    public fun get_order_amount(order: &Order): u64 {
        order.amount
    }

    public fun get_order_status(order: &Order): String {
        order.status
    }

    public fun get_seller_address(order: &Order): address {
        order.seller_address
    }

    public fun get_cart_add(cart: &Cart):address{
        cart.user_address
    }

    #[test_only]
    public entry fun test_register_user(
        registry: &mut TestUserRegistry,
        wallet_address: address,
        user_name: Option<String>,
        email: Option<String>,
        phone_number: Option<String>,
        house_address: Option<String>,
        ctx: &mut TxContext
    ) {
        assert!(wallet_address == sender(ctx), ENotOwner);
        assert!(!vec_map::contains(&registry.users, &wallet_address), EUserAlreadyRegistered);
        let user_id = object::new(ctx);
        let user = User {
            id: user_id,
            wallet_address,
            user_name,
            email,
            phone_number,
            house_address,
        };
        let user_id_value = object::uid_to_inner(&user.id);
        vec_map::insert(&mut registry.users, wallet_address, user_id_value);
        transfer::share_object(user);
    }

    public entry fun register_user(
        registry: &mut PlatformRegistry,
        wallet_address: address,
        user_name: Option<String>,
        email: Option<String>,
        phone_number: Option<String>,
        house_address: Option<String>,
        ctx: &mut TxContext
    ) {
        assert!(wallet_address == sender(ctx), ENotOwner);
        assert!(!vec_map::contains(&registry.users, &wallet_address), EUserAlreadyRegistered);
        let user_id = object::new(ctx);
        let user = User {
            id: user_id,
            wallet_address,
            user_name,
            email,
            phone_number,
            house_address,
        };
        let user_id_value = object::uid_to_inner(&user.id);
        vec_map::insert(&mut registry.users, wallet_address, user_id_value);
        transfer::share_object(user);
    }

    public entry fun add_product(
        store: &Store,
        product_name: String,
        image_cid: Option<String>,
        description: Option<String>,
        price: u64,
        quantity: u64,
        ctx: &mut TxContext
    ) {
        assert!(store.owner_address == sender(ctx), ENotOwner);
        let product_id = object::new(ctx);
        let product = Product {
            id: product_id,
            store_id: object::uid_to_inner(&store.id),
            product_name,
            image_cid,
            description,
            price,
            quantity,
        };
        transfer::share_object(product);
    }

    public entry fun create_cart(
        ctx: &mut TxContext
    ) {
        let user_address = sender(ctx);
        let cart_id = object::new(ctx);
        let cart = Cart {
            id: cart_id,
            user_address,
        };
        transfer::share_object(cart);
    }

    public fun create_store_internal(
        store_name: String,
        image_cid: Option<String>,
        description: Option<String>,
        share_link: String,
        ctx: &mut TxContext
    ): ID {
        let store_id = object::new(ctx);
        let owner_address = sender(ctx);
        let store = Store {
            id: store_id,
            store_name,
            image_cid,
            description,
            owner_address,
            share_link,
        };
        let store_id_value = object::uid_to_inner(&store.id);
        transfer::share_object(store);
        store_id_value
    }

    public entry fun add_to_cart(
        cart: &mut Cart,
        product: &Product,
        quantity: u64,
        ctx: &mut TxContext
    ) {
        let user_address = sender(ctx);
        assert!(cart.user_address == user_address, ENotOwner);
        let product_id = object::uid_to_inner(&product.id);
        if (dof::exists_(&cart.id, product_id)) {
            let cart_item: &mut CartItem = dof::borrow_mut(&mut cart.id, product_id);
            cart_item.quantity = cart_item.quantity + quantity;
        } else {
            let cart_item_id = object::new(ctx);
            let cart_item = CartItem {
                id: cart_item_id,
                cart_id: object::uid_to_inner(&cart.id),
                product_id,
                quantity,
            };
            dof::add(&mut cart.id, product_id, cart_item);
        }
    }

    public fun get_item_quantity(product: &Product): u64 {
        product.quantity
    }

    public fun get_product_id(product: &Product): &UID {
        &product.id
    }

    public fun get_store_id(store: &Store): ID {
        object::uid_to_inner(&store.id)
    }

    public fun get_owner_address(store: &Store): address {
        store.owner_address
    }

    public fun get_cart_id(cart: &Cart): &UID {
        &cart.id
    }

    public fun get_cart_item_quantity(cart_item: &CartItem): u64 {
        cart_item.quantity
    }

    public fun get_order_amount_value(order: &Order): u64 {
        order.amount
    }

    public entry fun checkout(
        _cart: &Cart,
        registry: &PlatformRegistry,
        cart: &mut Cart,
        products: vector<Product>,
        store: &Store,
        product_ids: vector<ID>,
        buyer_address: address,
        transaction_hash: String,
        payment: Coin<SUI>,
        ctx: &mut TxContext
    ) {
        let user_address = sender(ctx);
        assert!(vec_map::contains(&registry.users, &user_address), EUserNotRegistered);
        let user_id = *vec_map::get(&registry.users, &user_address);
        assert!(user_address == buyer_address, EInvalidBuyer);
        assert!(cart.user_address == user_address, ENotOwner);
        assert!(!vector::is_empty(&product_ids), EEmptyCart);
        assert!(vector::length(&product_ids) == vector::length(&products), EProductMismatch);
        let mut total_amount = 0;
        let mut i = 0;
        let len = vector::length(&product_ids);
        let seller_address = store.owner_address;
        let store_id = object::uid_to_inner(&store.id);
        while (i < len) {
            let product_id = *vector::borrow(&product_ids, i);
            let product = vector::borrow(&products, i);
            assert!(dof::exists_(&cart.id, product_id), EProductNotFound);
            assert!(object::uid_to_inner(&product.id) == product_id, EProductMismatch);
            assert!(product.store_id == store_id, EProductNotFound);
            let cart_item: &CartItem = dof::borrow(&cart.id, product_id);
            assert!(product.quantity >= cart_item.quantity, EInsufficientStock);
            let amount = product.price * cart_item.quantity;
            total_amount = total_amount + amount;
            let order_id = object::new(ctx);
            let order_id_str = string::utf8(b"order-");
            let order = Order {
                id: order_id,
                order_id: order_id_str,
                store_id,
                product_id,
                user_id,
                buyer_address,
                seller_address,
                amount,
                status: string::utf8(b"pending"),
                payment_status: string::utf8(b"confirmed"),
                transaction_hash: option::some(transaction_hash),
            };
            transfer::share_object(order);
            i = i + 1;
        };
        assert!(coin::value(&payment) >= total_amount, EInvalidBuyer);
        transfer::public_transfer(payment, seller_address);
        i = 0;
        while (i < len) {
            let product_id = *vector::borrow(&product_ids, i);
            let cart_item: CartItem = dof::remove(&mut cart.id, product_id);
            transfer::public_transfer(cart_item, @0x0);
            i = i + 1;
        };
        let mut products = products;
        while (!vector::is_empty(&products)) {
            let product = vector::pop_back(&mut products);
            transfer::public_transfer(product, @0x0);
        };
        vector::destroy_empty(products);
    }

    public entry fun update_order_status(
        order: &mut Order,
        store: &Store,
        status: String,
        ctx: &mut TxContext
    ) {
        assert!(store.owner_address == sender(ctx), ENotOwner);
        assert!(&order.store_id == &object::uid_to_inner(&store.id), ENotOwner);
        let valid_statuses = vector[
            string::utf8(b"pending"),
            string::utf8(b"shipped"),
            string::utf8(b"delivered"),
            string::utf8(b"cancelled"),
        ];
        assert!(vector::contains(&valid_statuses, &status), EInvalidStatus);
        order.status = status;
    }

    public fun get_user_id(registry: &PlatformRegistry, wallet_address: address): Option<ID> {
        if (vec_map::contains(&registry.users, &wallet_address)) {
            option::some(*vec_map::get(&registry.users, &wallet_address))
        } else {
            option::none()
        }
    }

    #[test_only]
    public fun test_get_user_id(registry: &TestUserRegistry, wallet_address: address): Option<ID> {
        if (vec_map::contains(&registry.users, &wallet_address)) {
            option::some(*vec_map::get(&registry.users, &wallet_address))
        } else {
            option::none()
        }
    }
