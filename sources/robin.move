module account::robin{ 
    use std::signer;
    use std::string::{String};
    use aptos_std::table::{Self, Table};
    use std::signer::address_of;

    const ROBINPROFILEEXIST: u64 = 1;
    const ROBINPROFILENOTFOUND: u64 = 2;
    const NOT_INIZIALITATE: u64 = 3;
    const OK_INIZIALITATE: u64 = 4;

    struct RobinProfile has copy, drop, key, store{
        nickname: String,
        bio: String,
    }

    struct RobinPost has store, drop, key, copy {
        content: String,
        comments: String,
        author_comment: String,
    }

    struct RobinAccount has key, store{
        record: Table<RobinProfile, RobinPost>
    }


    // Inizialitate
    public entry fun inizialitate(user: &signer) {
        assert!(!exists<RobinAccount>(address_of(user)), NOT_INIZIALITATE);
        move_to(user, RobinAccount{record: table::new<RobinProfile, RobinPost>(),
        });
    }

    //Crear un perfil
    public entry fun robin_create_profile(user: &signer, nickname: String, bio: String, content: String, comments: String, author_comment: String) acquires RobinAccount {
        let recordaccount = borrow_global_mut<RobinAccount>(address_of(user));
        assert!(!table::contains(&recordaccount.record, RobinProfile{nickname, bio}), ROBINPROFILENOTFOUND);

        table::add(&mut recordaccount.record, RobinProfile{nickname, bio}, RobinPost{content, comments, author_comment});
    }

    #[view]
    //Obtain record of RobinAccount
    public fun record_info(account: address, nickname: String, bio: String): RobinPost acquires RobinAccount {
        assert!(exists<RobinAccount>(account), NOT_INIZIALITATE);
        let info= borrow_global<RobinAccount>(account);
        let response = table::borrow(&info.record, RobinProfile{nickname, bio});
        *response
    }
    
    // Edit the content post
    public entry fun edit_post(account: &signer, nickname: String, bio: String, content: String) acquires RobinAccount{
        assert!(exists<RobinAccount>(address_of(account)), NOT_INIZIALITATE);

        let info= borrow_global_mut<RobinAccount>(address_of(account));
        //assert!(table::contains(&registros.registros, Nombre { nombre }), REGISTRO_NO_EXISTE);
        assert!(table::contains(&info.record, RobinProfile{nickname, bio}), ROBINPROFILENOTFOUND);

        let post_current = &mut table::borrow_mut(&mut info.record, RobinProfile{nickname, bio}).content;
        *post_current = content;
    }

    //Edit nickname
    public entry fun edit_nickname(account: &signer, current_nickname: String, new_nickname: String, bio: String) acquires RobinAccount{
        assert!(exists<RobinAccount>(address_of(account)), NOT_INIZIALITATE);
        let info= borrow_global_mut<RobinAccount>(address_of(account));
        //assert!(table::contains(&registros.registros, Nombre { nombre }), REGISTRO_NO_EXISTE);
        assert!(table::contains(&info.record, RobinProfile{nickname: current_nickname, bio}), 102);
        assert!(table::contains(&info.record, RobinProfile{nickname: new_nickname, bio}), ROBINPROFILENOTFOUND);

        let profile = table::borrow(&info.record, RobinProfile{nickname: current_nickname, bio});
        table::add(&mut info.record, RobinProfile {nickname: new_nickname, bio}, *profile);
        table::remove(&mut info.record, RobinProfile{nickname: current_nickname, bio});
    }

    //Edit bio
    public entry fun edit_bio(account: &signer, nickname: String, last_bio: String, new_bio: String) acquires RobinAccount{
        assert!(exists<RobinAccount>(address_of(account)), NOT_INIZIALITATE);
        let info= borrow_global_mut<RobinAccount>(address_of(account));
        //assert!(table::contains(&registros.registros, Nombre { nombre }), REGISTRO_NO_EXISTE);
        assert!(table::contains(&info.record, RobinProfile{nickname, bio: last_bio}), ROBINPROFILENOTFOUND);
        assert!(table::contains(&info.record, RobinProfile{nickname, bio: new_bio}), ROBINPROFILEEXIST);

        let profile = table::borrow(&info.record, RobinProfile{nickname, bio: last_bio});
        table::add(&mut info.record, RobinProfile {nickname, bio: new_bio}, *profile);
        table::remove(&mut info.record, RobinProfile{nickname, bio: last_bio});
    }

    //Edit comment
    public entry fun edit_comment(account: &signer, nickname: String, bio: String, comments: String) acquires RobinAccount{
        assert!(exists<RobinAccount>(address_of(account)), NOT_INIZIALITATE);

        let info= borrow_global_mut<RobinAccount>(address_of(account));
        assert!(table::contains(&info.record, RobinProfile{nickname, bio}), ROBINPROFILENOTFOUND);

        let post_current = &mut table::borrow_mut(&mut info.record, RobinProfile{nickname, bio}).comments;
        *post_current = comments;
    }

    //Eliminar postcontents
    public entry fun deleate_posts(account: &signer, nickname: String, bio: String) acquires RobinAccount {
        assert!(exists<RobinAccount>(address_of(account)), NOT_INIZIALITATE);

        let info= borrow_global_mut<RobinAccount>(address_of(account));
        assert!(table::contains(&info.record, RobinProfile{nickname, bio}), ROBINPROFILENOTFOUND);

        table::remove(&mut info.record, RobinProfile{nickname, bio});
    }

}

