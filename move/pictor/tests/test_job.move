#[test_only]
#[allow(unused_use)]
module pictor::test_job;

use sui::test_scenario as ts;
use std::string;
use std::debug;
use pictor::pictor::{Self, Service};

#[test]
fun test_init(){

    let owner = @0xA;
    let mut ts = ts::begin(owner);        

    let service_name = string::utf8(b"PictorJobService");
    let service: Service = pictor::create_service_test(service_name, ts.ctx());

    //let service_id = pictor::get_service_id(&service);    
    //debug::print(&service_id);      

    //verify
    let verify_name = pictor::get_service_name(&service);
    assert!(verify_name == service_name, 0);
    
    transfer::public_transfer(service, owner);     

    ts::end(ts);
}

#[test]
fun test_create_job() {

    let owner = @0xA;
    let mut ts = ts::begin(owner);
    //let alice = @0xA;    
    
    //create a job and transfer it to owner.
    {   
        ts::next_tx(&mut ts, owner);
        
        let service_name = string::utf8(b"PictorJobService");
        let mut service: Service = pictor::create_service_test(service_name, ts.ctx());
                
        let job_id = service.create_new_job(owner, string::utf8(b"job1"), 1, 1, 10, ts.ctx());
        //debug::print(&job_id);

        //verify job
        let job_exists = service.is_job_exists(job_id);
        assert!(job_exists, 1);

        //transfer::public_transfer(job, owner);
        transfer::public_transfer(service, owner);
        
    };

    ts::end(ts);
}

#[test]
fun test_update_job() {
    
    let owner = @0xA;
    let mut ts = ts::begin(owner);
    
    ts::next_tx(&mut ts, owner);
        
    let service_name = string::utf8(b"PictorJobService");
    let mut service: Service = pictor::create_service_test(service_name, ts.ctx());
            
    let job_id = service.create_new_job(owner, string::utf8(b"job1"), 1, 1, 10, ts.ctx());
    
    //update user_id, job_type_id, time_out, status, estimated_cost
    service.update_job(job_id, 1, 1, 200, 1, 1000);

    //verify 
    let estimated_cost = service.get_estimated_cost(job_id);

    // status user_id == 1, job_type_id == 1, time_out == 200, status == 1, estimated_cost == 1000
    assert!(estimated_cost == 1000, 2);
    
    transfer::public_transfer(service, owner);

    ts::end(ts);

}

#[test]
fun test_delete_job() {
    
    let owner = @0xA;
    let mut ts = ts::begin(owner);
    
    //create a job and transfer it to owner.
    {   
        ts::next_tx(&mut ts, owner);
        
        let service_name = string::utf8(b"PictorJobService");
        let mut service: Service = pictor::create_service_test(service_name, ts.ctx());
                
        let job_id = service.create_new_job(owner, string::utf8(b"job1"), 1, 1, 10, ts.ctx());
        
        //remove job
        service.remove_job_test(job_id);

        //verify job
        let job_exists = service.is_job_exists(job_id);

        assert!(!job_exists, 3);
        
        transfer::public_transfer(service, owner);
        
    };

    ts::end(ts);

}

#[test]
fun test_update_job_status() {
    
    let owner = @0xA;
    let mut ts = ts::begin(owner);
    
    ts::next_tx(&mut ts, owner);
        
    let service_name = string::utf8(b"PictorJobService");
    let mut service: Service = pictor::create_service_test(service_name, ts.ctx());
            
    let job_id = service.create_new_job(owner, string::utf8(b"job1"), 1, 1, 10, ts.ctx());
    
    //update job status to 5
    service.set_job_status(job_id, 5);

    //verify job status
    let job_status = service.get_job_status(job_id);

    // status must equals to 5
    assert!(job_status == 5, 4);
    
    transfer::public_transfer(service, owner);

    ts::end(ts);

}

#[test]
fun test_update_estimated_cost() {
    
    let owner = @0xA;
    let mut ts = ts::begin(owner);
    
    ts::next_tx(&mut ts, owner);
        
    let service_name = string::utf8(b"PictorJobService");
    let mut service: Service = pictor::create_service_test(service_name, ts.ctx());
            
    let job_id = service.create_new_job(owner, string::utf8(b"job1"), 1, 1, 10, ts.ctx());
    
    //update job estimated_cost to 100
    service.set_estimated_cost(job_id, 100);

    //verify job estimated_cost
    let estimated_cost = service.get_estimated_cost(job_id);

    //debug::print(&estimated_cost);

    //estimated_cost must equals to 100
    assert!(estimated_cost == 100, 5);
    
    transfer::public_transfer(service, owner);

    ts::end(ts);

}
