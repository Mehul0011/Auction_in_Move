module addr::Counter {
    use std::signer;
    use std::option;
    
    // use aptos_framework::account;
    struct Counter has key, store {
        val: u256
    }

    const ERROR: u64 = 1;
    const ERROR_INITIALISING: u64 = 2;

    public entry fun initialise(account: &signer) {
        let signer_address = signer::address_of(account);
        if(!exists<Counter>(signer_address)){
            let zero = Counter{val: 0};
            move_to(account, zero);
        };
    }

    #[view]
    public fun get_counter(owner: address): option::Option<u256> acquires Counter {
        let counter;
        if(exists<Counter>(owner)) {
            counter = borrow_global<Counter>(owner).val;
            option::some(counter)
        }
        else {
            option::none()
        }
    }

    public entry fun increment(account: &signer) acquires Counter {
        let signer_address = signer::address_of(account);

        if(!exists<Counter>(signer_address)) {
            initialise(account);    
        };

        let counter = borrow_global_mut<Counter>(signer_address);
        counter.val = counter.val + 1;
    }

    public entry fun delete_counter(account: &signer) acquires Counter {
        let signer_address = signer::address_of(account);
        let counter = move_from<Counter>(signer_address);
        let Counter { val: _ } = counter;
    }


    #[test_only]
    use std::debug;

    #[test(account=@addr)]
    public fun test_counter(account: &signer) acquires Counter {
        use std::string;
        debug::print(&get_counter(signer::address_of(account)));
        initialise(account);

        let counter = get_counter(signer::address_of(account));
        debug::print(&counter);
        debug::print(&string::utf8(b"Hello: "));
        
        assert!(counter == option::some(0), ERROR_INITIALISING);
        
        increment(account);
        assert!(get_counter(signer::address_of(account)) == option::some(1), ERROR);
        
        delete_counter(account);
        assert!(get_counter(signer::address_of(account)) == option::none(), ERROR);
    }
}