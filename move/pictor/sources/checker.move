#[allow(unused_use)]
module pictor::checker;
use std::string::String;

const EInvalidContentLen: u64 = 1;
const MIN_CONTENT_LEN: u64 = 1;
const MAX_CONTENT_LEN: u64 = 1000;

public struct Checker has key, store {
    id: UID,
    owner: address,       
    content: String,
    device_id: String,     
    user_id: u64,    
    status: u64,    
    created_at: u64
}

//create new checker node
public fun new(    
    owner: address,
    content:String,     
    device_id:String,  
    user_id: u64,          
    ctx: &mut TxContext
): Checker {
    let len = content.length();
    assert!(len > MIN_CONTENT_LEN && len <= MAX_CONTENT_LEN, EInvalidContentLen);    
    Checker {
        id: object::new(ctx),        
        owner,        
        content,
        device_id,
        user_id,        
        status: 0,        
        created_at: ctx.epoch_timestamp_ms()
    }
}

/// Deletes
public fun delete(checker: Checker) {
    let Checker {
        id,
        owner: _,        
        content: _,
        device_id: _,
        user_id: _,        
        status: _,        
        created_at: _,        
    } = checker;
    object::delete(id);
}

/// update checker
public fun update(checker: &mut Checker, user_id: u64, content: String, device_id: String, status: u64 ){
    checker.user_id = user_id;
    checker.content = content;
    checker.device_id = device_id;
    checker.status = status;    
}

/// update a checker status
public fun update_status(checker: &mut Checker, status: u64) {
    checker.status = status;    
}

//Get checker id
public fun get_id(checker:&Checker): ID {
    checker.id.to_inner()
}

//Get checker user_id
public fun get_user_id(checker:&Checker): u64 {
    checker.user_id
}

//Get checker content
public fun get_content(checker:&Checker): String {
    checker.content
}

//Get checker device_id
public fun get_device_id(checker:&Checker): String {
    checker.device_id
}

//Get checker status
public fun get_status(checker:&Checker): u64 {
    checker.status
}

//Get checker created_at
public fun get_created_at(checker:&Checker): u64 {
    checker.created_at
}