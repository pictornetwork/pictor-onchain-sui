#[test_only]
#[allow(unused_use)]
module pictor::test_worker;

use sui::test_scenario as ts;
use std::string;
use std::debug;
use pictor::pictor::{Self, Service};

#[test]
fun test_create_worker() {

    let owner = @0xA;
    let mut ts = ts::begin(owner);
        
    //create a job and transfer it to owner.
    {   
        ts::next_tx(&mut ts, owner);
        
        let service_name = string::utf8(b"PictorJobService");
        let mut service: Service = pictor::create_service_test(service_name, ts.ctx());

        let user_id = 1;
        let mac_address = string::utf8(b"00-50-56-C0-00-01");
                
        let worker_id = service.create_new_worker(owner, string::utf8(b"worker1"), user_id, mac_address, ts.ctx());

        //debug::print(&worker_id);

        //verify job
        let is_exists = service.is_worker_exists(worker_id);

        assert!(is_exists, 1);
        
        transfer::public_transfer(service, owner);
        
    };

    ts::end(ts);
}

#[test]
fun test_update_worker() {
    
    let owner = @0xA;
    let mut ts = ts::begin(owner);
    
    ts::next_tx(&mut ts, owner);
        
    let service_name = string::utf8(b"PictorJobService");
    let mut service: Service = pictor::create_service_test(service_name, ts.ctx());
            
    let mut content = string::utf8(b"worker1");       
    let mut user_id = 1;
    let mut mac_address = string::utf8(b"00-50-56-C0-00-01");

    let status = 1;
            
    let worker_id = service.create_new_worker(owner, content, user_id, mac_address, ts.ctx());
    
    //update content, mac_address, user_id, status
    content = string::utf8(b"worker2");
    user_id = 2;
    mac_address = string::utf8(b"00-50-56-C0-00-08");

    service.update_worker(worker_id, content, mac_address, user_id, status);

    //verify     
    let worker_status = service.get_worker_status(worker_id);
        
    assert!(worker_status == status , 2);
    
    transfer::public_transfer(service, owner);

    ts::end(ts);

}

#[test]
fun test_delete_worker() {
    
    let owner = @0xA;
    let mut ts = ts::begin(owner);
    
    //create a job and transfer it to owner.
    {   
        ts::next_tx(&mut ts, owner);
        
        let service_name = string::utf8(b"PictorJobService");
        let mut service: Service = pictor::create_service_test(service_name, ts.ctx());
                
        let content = string::utf8(b"worker1");       
        let user_id = 1;
        let mac_address = string::utf8(b"00-50-56-C0-00-01");
                                
        let worker_id = service.create_new_worker(owner, content, user_id, mac_address, ts.ctx());
        
        //remove job
        service.remove_worker_test(worker_id);

        //verify job
        let is_exists = service.is_worker_exists(worker_id);

        assert!(!is_exists, 3);
        
        transfer::public_transfer(service, owner);
        
    };

    ts::end(ts);

}

#[test]
fun test_update_worker_status() {
    
    let owner = @0xA;
    let mut ts = ts::begin(owner);
    
    ts::next_tx(&mut ts, owner);
        
    let service_name = string::utf8(b"PictorJobService");
    let mut service: Service = pictor::create_service_test(service_name, ts.ctx());
            
    let content = string::utf8(b"worker1");       
    let user_id = 1;
    let mac_address = string::utf8(b"00-50-56-C0-00-01");
    let status = 5;

    let worker_id = service.create_new_worker(owner, content, user_id, mac_address, ts.ctx());
    
    //update job status to 5
    service.set_worker_status(worker_id, status);
    
    //verify    
    let worker_status = service.get_worker_status(worker_id);
        
    assert!(worker_status == status , 4);
        
    transfer::public_transfer(service, owner);

    ts::end(ts);

}
