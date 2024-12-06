module pictor::pictor;

use std::string::String;
use sui::event;
use sui::coin::{Self, Coin, TreasuryCap};
use sui::dynamic_field as df;
use sui::object_table::{Self, ObjectTable};

use pictor::job::{Self, Job};
use pictor::worker::{Self, Worker};
use pictor::checker::{Self, Checker};

//const EInvalidPermission: u64 = 1;
//const ENotEnoughBalance: u64 = 2;
const ENotExists: u64 = 3;

/// A capability that can be used to perform admin operations on a service
public struct AdminCap has key, store {
    id: UID,
    service_id: ID
}

/// Represents a job record
public struct JobRecord has store, drop {    
    owner: address,    
    user_id: u64,
    job_type_id: u64,
    time_out: u64,
    status: u64,
    estimated_cost: u64
}

// Represents a object created event
public struct ItemCreated has copy, drop {
    item: ID,
    created_at: u64
}

/// Represents a worker record
public struct WorkerRecord has store, drop {    
    owner: address,        
    content: String,
    mac_address: String,
    user_id: u64,    
    status: u64,    
    created_at: u64    
}

/// Represents a checker record
public struct CheckerRecord has store, drop {    
    owner: address,       
    content: String,
    device_id: String,     
    user_id: u64,    
    status: u64,    
    created_at: u64
}

// PICTOR TOKEN
public struct PICTOR has drop {}

/// Represents a service
public struct Service has key, store {
    id: UID,        
    jobs: ObjectTable<ID, Job>,
    workers: ObjectTable<ID, Worker>,
    checkers: ObjectTable<ID, Checker>,    
    name: String
}

// INIT
fun init(witness: PICTOR, ctx: &mut TxContext) {
    //create token
    let (treasury_cap, metadata) = coin::create_currency(
            witness,
            6,
            b"PICTOR",
            b"",
            b"",
            option::none(),
            ctx,
    );
    transfer::public_freeze_object(metadata);
    transfer::public_transfer(treasury_cap, ctx.sender());
}

#[test_only]
/// Wrapper of module initializer for testing
public fun test_init(ctx: &mut TxContext) {
    init(PICTOR {}, ctx)
}

//mint coint
public fun mint(
    treasury_cap: &mut TreasuryCap<PICTOR>,
    amount: u64,
    recipient: address,
    ctx: &mut TxContext,
) {
    let coin = coin::mint(treasury_cap, amount, ctx);
    transfer::public_transfer(coin, recipient);
}

/// Manager can burn coins
public fun burn(treasury_cap: &mut TreasuryCap<PICTOR>, coin: Coin<PICTOR>) {
    coin::burn(treasury_cap, coin);
}

//create service
#[allow(lint(self_transfer))]
public fun create_service(name: String, ctx: &mut TxContext): ID {
        
    let id = object::new(ctx);
    let service_id = id.to_inner();

    let service = Service {
        id,        
        jobs: object_table::new(ctx),
        workers: object_table::new(ctx),
        checkers: object_table::new(ctx),        
        name
    };
   
    let admin_cap = AdminCap {
        id: object::new(ctx),
        service_id
    };

    transfer::transfer(service, tx_context::sender(ctx));
    transfer::transfer(admin_cap, tx_context::sender(ctx));

    service_id

}

#[test_only]
public fun create_service_test(name: String, ctx: &mut TxContext): Service {        
    let id = object::new(ctx);    
    Service {
        id,        
        jobs: object_table::new(ctx),
        workers: object_table::new(ctx),
        checkers: object_table::new(ctx),        
        name
    }
}

#[test_only]
public fun create_admin_cap_test(service_id: ID, ctx: &mut TxContext): AdminCap {        
    AdminCap {
        id: object::new(ctx),
        service_id
    }
}

/// Add a new job
public fun create_new_job(
    service: &mut Service,
    owner: address,
    content: String,
    user_id: u64,
    job_type_id: u64,
    estimated_cost: u64,        
    ctx: &mut TxContext
): ID {
    let item = job::new_job(
        owner,        
        content,
        user_id,
        job_type_id,
        estimated_cost,        
        ctx
    );
    let job_id = job::get_id(&item);
    service.add_job(item, owner);    
    // Create an instance of `JobCreated` and pass it to `event::emit`.
    event::emit(ItemCreated {
        item: job_id,
        created_at: ctx.epoch_timestamp_ms()
    });
    //return job id    
    job_id
}

/// Adds a Job to the service
fun add_job(
    service: &mut Service,
    job: Job,
    owner: address    
) {
    let job_id = job.get_id();
    let user_id = job.get_user_id();
    let job_type_id = job.get_job_type_id();
    let time_out = job.get_time_out();
    let status = job.get_status();
    let estimated_cost = job.get_estimated_cost();

    service.jobs.add(job_id, job);    

    df::add(&mut service.id, job_id, JobRecord { owner, user_id, job_type_id, time_out, status, estimated_cost });    

}

/// Removes a job (only admin can do this)
public fun remove_job(
    _: &AdminCap,
    service: &mut Service,
    job_id: ID,
) {
    assert!(service.jobs.contains(job_id), ENotExists);
    let _record: JobRecord = df::remove(&mut service.id, job_id);        
    service.jobs.remove(job_id).delete_job();
}

// Update job
public fun update_job(    
    service: &mut Service,
    job_id: ID,
    user_id: u64,
    job_type_id: u64,
    time_out: u64,
    status: u64,
    estimated_cost: u64        
) {
    assert!(service.jobs.contains(job_id), ENotExists);
    
    let job = &mut service.jobs[job_id];
    
    //update job
    job.update_job(user_id, job_type_id, time_out, status, estimated_cost);
    
    //update record
    let record = df::borrow_mut<ID, JobRecord>(&mut service.id, job_id);
    record.user_id = user_id;
    record.job_type_id = job_type_id;
    record.time_out = time_out;
    record.status = status;
    record.estimated_cost = estimated_cost;

}

/// Update job status
public fun set_job_status(service: &mut Service, job_id: ID, status: u64) {
    let job = &mut service.jobs[job_id];
    job.update_job_status(status);
    let record = df::borrow_mut<ID, JobRecord>(&mut service.id, job_id);
    record.status = status;
}

/// Get job status
public fun get_job_status(service: &mut Service, job_id: ID): u64 {
    let job = &mut service.jobs[job_id];
    job.get_status()
}

/// Update job estimated cost
public fun set_estimated_cost(service: &mut Service, job_id: ID, estimated_cost: u64) {
    let job = &mut service.jobs[job_id];
    job.update_job_estimated_cost(estimated_cost);
    let record = df::borrow_mut<ID, JobRecord>(&mut service.id, job_id);
    record.estimated_cost = estimated_cost;    
}

/// Get job estimated cost
public fun get_estimated_cost(service: &mut Service, job_id: ID): u64 {
    let job = &mut service.jobs[job_id];
    job.get_estimated_cost()
}

// Get job by ID
public fun get_job(service: &mut Service, job_id: ID): &JobRecord {
    assert!(df::exists_(&service.id, job_id), ENotExists);
    df::borrow<ID, JobRecord>(&service.id, job_id)    
}

// Get service id
public fun get_service_id(service: &Service): ID {
    service.id.to_inner()
}

// Get service name
public fun get_service_name(service: &Service): String {
    service.name
}

// Check job exists
public fun is_job_exists(service: &Service, id: ID): bool {
    service.jobs.contains(id)
}

// Check worker exists
public fun is_worker_exists(service: &Service, id: ID): bool {
    service.workers.contains(id)
}

// Check checker exists
public fun is_checker_exists(service: &Service, id: ID): bool {
    service.checkers.contains(id)
}

//worker
/// Add a new worker
public fun create_new_worker(
    service: &mut Service,
    owner: address,
    content: String,
    user_id: u64,   
    mac_address: String,     
    ctx: &mut TxContext
): ID {
    let item = worker::new(
        owner,        
        content,
        mac_address,
        user_id,                
        ctx
    );
    let worker_id = worker::get_id(&item);
    service.add_worker(item, owner);    
    //raise event
    event::emit(ItemCreated {
        item: worker_id,
        created_at: ctx.epoch_timestamp_ms()
    });
    worker_id
}

/// Adds a Worker to the service
fun add_worker(
    service: &mut Service,
    worker: Worker,
    owner: address    
) {

    let worker_id = worker.get_id();
    let user_id = worker.get_user_id();
    let content = worker.get_content();    
    let mac_address = worker.get_mac_address();    
    let status = worker.get_status();
    let created_at = worker.get_created_at();
    
    service.workers.add(worker_id, worker);    

    df::add(&mut service.id, worker_id, WorkerRecord { owner, content, mac_address, user_id, status, created_at });    

}

// Update worker
public fun update_worker(    
    service: &mut Service,
    worker_id: ID,
    content: String,
    mac_address: String,
    user_id: u64,
    status: u64        
) {
    assert!(service.workers.contains(worker_id), ENotExists);
    
    let worker = &mut service.workers[worker_id];
    
    //update worker
    worker.update(user_id, content, mac_address, status);
    
    //update record
    let record = df::borrow_mut<ID, WorkerRecord>(&mut service.id, worker_id);

    record.user_id = user_id;
    record.content = content;
    record.mac_address = mac_address;
    record.status = status;    

}

/// Removes a worker (only admin can do this)
public fun remove_worker(
    _: &AdminCap,
    service: &mut Service,
    worker_id: ID,
) {
    assert!(service.workers.contains(worker_id), ENotExists);
    let _record: WorkerRecord = df::remove(&mut service.id, worker_id);        
    service.workers.remove(worker_id).delete();
}

// Update worker status
public fun set_worker_status(service: &mut Service, worker_id: ID, status: u64){
    assert!(service.workers.contains(worker_id), ENotExists);

    let worker = &mut service.workers[worker_id];    
    //update worker
    worker.update_status(status);
    
    let record = df::borrow_mut<ID, WorkerRecord>(&mut service.id, worker_id);     
    record.status = status;
}

// Get worker status
public fun get_worker_status(service: &mut Service, worker_id: ID): u64 {
    assert!(df::exists_(&service.id, worker_id), ENotExists);
    let worker = &mut service.workers[worker_id];
    worker.get_status()      
}

// Get worker by ID
public fun get_worker(service: &mut Service, worker_id: ID): &mut WorkerRecord {
    assert!(df::exists_(&service.id, worker_id), ENotExists);
    df::borrow_mut<ID, WorkerRecord>(&mut service.id, worker_id)    
}

//checker
/// Add a new checker
public fun create_new_checker(
    service: &mut Service,
    owner: address,
    content: String,
    user_id: u64,   
    device_id: String,     
    ctx: &mut TxContext
): ID {
    let item = checker::new(
        owner,        
        content,
        device_id,
        user_id,                
        ctx
    );
    let checker_id = checker::get_id(&item);
    service.add_checker(item, owner);  
    //raise event
    event::emit(ItemCreated {
        item: checker_id,
        created_at: ctx.epoch_timestamp_ms()
    });  
    checker_id
}

/// Adds a Checker to the service
fun add_checker(
    service: &mut Service,
    checker: Checker,
    owner: address    
) {

    let checker_id = checker.get_id();
    let user_id = checker.get_user_id();
    let content = checker.get_content();    
    let device_id = checker.get_device_id();    
    let status = checker.get_status();
    let created_at = checker.get_created_at();
    
    service.checkers.add(checker_id, checker);    

    df::add(&mut service.id, checker_id, CheckerRecord { owner, content, device_id, user_id, status, created_at });    

}

// Update checker
public fun update_checker(    
    service: &mut Service,
    checker_id: ID,
    content: String,
    device_id: String,
    user_id: u64,
    status: u64        
) {
    assert!(service.checkers.contains(checker_id), ENotExists);
    
    let checker = &mut service.checkers[checker_id];
    
    //update checker
    checker.update(user_id, content, device_id, status);
    
    //update record
    let record = df::borrow_mut<ID, CheckerRecord>(&mut service.id, checker_id);

    record.user_id = user_id;
    record.content = content;
    record.device_id = device_id;
    record.status = status;    

}

/// Removes a checker (only admin can do this)
public fun remove_checker(
    _: &AdminCap,
    service: &mut Service,
    checker_id: ID,
) {
    assert!(service.checkers.contains(checker_id), ENotExists);
    let _record: CheckerRecord = df::remove(&mut service.id, checker_id);        
    service.checkers.remove(checker_id).delete();
}

// Update checker status
public fun set_checker_status(service: &mut Service, checker_id: ID, status: u64){
    assert!(service.checkers.contains(checker_id), ENotExists);

    let checker = &mut service.checkers[checker_id];    
    //update checker
    checker.update_status(status);
    
    let record = df::borrow_mut<ID, CheckerRecord>(&mut service.id, checker_id);     
    record.status = status;
}

// Get checker status
public fun get_checker_status(service: &mut Service, checker_id: ID): u64 {
    assert!(df::exists_(&service.id, checker_id), ENotExists);
    let checker = &mut service.checkers[checker_id];
    checker.get_status()      
}


#[test_only]
public fun remove_job_test(    
    service: &mut Service,
    job_id: ID,
) {
    assert!(service.jobs.contains(job_id), ENotExists);
    let _record: JobRecord = df::remove(&mut service.id, job_id);        
    service.jobs.remove(job_id).delete_job();
}

#[test_only]
public fun remove_worker_test(    
    service: &mut Service,
    worker_id: ID,
) {
    assert!(service.workers.contains(worker_id), ENotExists);
    let _record: WorkerRecord = df::remove(&mut service.id, worker_id);        
    service.workers.remove(worker_id).delete();
}

#[test_only]
public fun remove_checker_test(    
    service: &mut Service,
    checker_id: ID,
) {
    assert!(service.checkers.contains(checker_id), ENotExists);
    let _record: CheckerRecord = df::remove(&mut service.id, checker_id);        
    service.checkers.remove(checker_id).delete();
}
