module pictor::job;
use std::string::String;
//use sui::clock::Clock;

const EInvalidContentLen: u64 = 1;
const MIN_CONTENT_LEN: u64 = 1;
const MAX_CONTENT_LEN: u64 = 1000;

public struct Job has key, store {
    id: UID,
    owner: address,        
    content: String,
    user_id: u64,
    job_type_id: u64,
    time_out: u64,
    status: u64,
    estimated_cost: u64,
    created_at: u64
}

//create new job
public(package) fun new_job(    
    owner: address,
    content:String,       
    user_id: u64,
    job_type_id: u64,
    estimated_cost: u64,      
    ctx: &mut TxContext
): Job {
    let len = content.length();
    assert!(len > MIN_CONTENT_LEN && len <= MAX_CONTENT_LEN, EInvalidContentLen);    
    Job {
        id: object::new(ctx),        
        owner,        
        content,
        user_id,
        job_type_id,
        time_out: 0,
        status: 0,
        estimated_cost,
        created_at: ctx.epoch_timestamp_ms()
    }
}

/// Deletes a job
public(package) fun delete_job(job: Job) {
    let Job {
        id,
        owner: _,        
        content: _,
        user_id: _,
        job_type_id: _,
        time_out: _,
        status: _,
        estimated_cost: _,        
        created_at: _,        
    } = job;
    object::delete(id);
}

/// update job
public fun update_job(job: &mut Job, user_id: u64, job_type_id: u64, time_out: u64, status: u64, estimated_cost: u64 ){
    job.user_id = user_id;
    job.job_type_id = job_type_id;
    job.time_out = time_out;
    job.status = status;
    job.estimated_cost = estimated_cost;    
}

/// update job estimated cost
public fun update_job_estimated_cost(job: &mut Job, estimated_cost: u64){
    job.estimated_cost = estimated_cost;    
}

/// update a job status
public fun update_job_status(job: &mut Job, status: u64) {
    job.status = status;    
}

// return job id
public fun get_id(job: &Job): ID {
    job.id.to_inner()
}

// return user_id
public fun get_user_id(job: &Job): u64 {
    job.user_id
}

// return job_type_id
public fun get_job_type_id(job: &Job): u64 {
    job.job_type_id
}

// return time_out
public fun get_time_out(job: &Job): u64 {
    job.time_out
}

// return status
public fun get_status(job: &Job): u64 {
    job.status
}

// return estimated_cost
public fun get_estimated_cost(job: &Job): u64 {
    job.estimated_cost
}
