#[allow(unused_use)]
module pictor::worker;
use std::string::String;

const EInvalidContentLen: u64 = 1;
const MIN_CONTENT_LEN: u64 = 1;
const MAX_CONTENT_LEN: u64 = 1000;

public struct Worker has key, store {
    id: UID,
    owner: address,        
    content: String,
    mac_address: String,
    user_id: u64,    
    status: u64,    
    created_at: u64
}

//create new job
public fun new(    
    owner: address,
    content:String,         
    mac_address:String,  
    user_id: u64,              
    ctx: &mut TxContext
): Worker {
    let len = content.length();
    assert!(len > MIN_CONTENT_LEN && len <= MAX_CONTENT_LEN, EInvalidContentLen);    
    Worker {
        id: object::new(ctx),        
        owner,        
        content,
        mac_address,
        user_id,        
        status: 0,        
        created_at: ctx.epoch_timestamp_ms()
    }
}

/// Deletes a job
public fun delete(worker: Worker) {
    let Worker {
        id,
        owner: _,        
        content: _,
        mac_address: _,
        user_id: _,        
        status: _,        
        created_at: _,        
    } = worker;
    object::delete(id);
}

/// update worker
public fun update(worker: &mut Worker, user_id: u64, content: String, mac_address: String, status: u64 ){
    worker.user_id = user_id;
    worker.content = content;
    worker.mac_address = mac_address;
    worker.status = status;    
}

/// update a worker status
public fun update_status(worker: &mut Worker, status: u64) {
    worker.status = status;    
}

//Get worker id
public fun get_id(worker:&Worker): ID {
    worker.id.to_inner()
}

//Get worker user_id
public fun get_user_id(worker:&Worker): u64 {
    worker.user_id
}

//Get worker content
public fun get_content(worker:&Worker): String {
    worker.content
}

//Get worker mac_address
public fun get_mac_address(worker:&Worker): String {
    worker.mac_address
}

//Get worker status
public fun get_status(worker:&Worker): u64 {
    worker.status
}

//Get worker created_at
public fun get_created_at(worker:&Worker): u64 {
    worker.created_at
}
