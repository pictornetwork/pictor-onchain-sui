#[test_only]
#[allow(unused_use)]
module pictor::test_checker;

use sui::test_scenario as ts;
use std::string;
use std::debug;
use pictor::pictor::{Self, Service};

#[test]
fun test_create_checker() {

    let owner = @0xA;
    let mut ts = ts::begin(owner);
        
    //create a job and transfer it to owner.
    {   
        ts::next_tx(&mut ts, owner);
        
        let service_name = string::utf8(b"PictorJobService");
        let mut service: Service = pictor::create_service_test(service_name, ts.ctx());

        let user_id = 1;
        let device_id = string::utf8(b"00330-81486-23222-AA048");
                
        let checker_id = service.create_new_checker(owner, string::utf8(b"checker1"), user_id, device_id, ts.ctx());

        //debug::print(&checker_id);

        //verify job
        let is_exists = service.is_checker_exists(checker_id);

        assert!(is_exists, 1);
        
        transfer::public_transfer(service, owner);
        
    };

    ts::end(ts);
}

#[test]
fun test_update_checker() {
    
    let owner = @0xA;
    let mut ts = ts::begin(owner);
    
    ts::next_tx(&mut ts, owner);
        
    let service_name = string::utf8(b"PictorJobService");
    let mut service: Service = pictor::create_service_test(service_name, ts.ctx());
            
    let mut content = string::utf8(b"checker1");       
    let mut user_id = 1;
    let mut device_id = string::utf8(b"00330-81486-23222-AA048");

    let status = 1;
            
    let checker_id = service.create_new_checker(owner, content, user_id, device_id, ts.ctx());
    
    //update content, device_id, user_id, status
    content = string::utf8(b"worker2");
    user_id = 2;
    device_id = string::utf8(b"00330-81486-23222-BB149");

    service.update_checker(checker_id, content, device_id, user_id, status);

    //verify     
    let worker_status = service.get_checker_status(checker_id);
        
    assert!(worker_status == status , 2);
    
    transfer::public_transfer(service, owner);

    ts::end(ts);

}

#[test]
fun test_delete_checker() {
    
    let owner = @0xA;
    let mut ts = ts::begin(owner);
    
    //create a job and transfer it to owner.
    {   
        ts::next_tx(&mut ts, owner);
        
        let service_name = string::utf8(b"PictorJobService");
        let mut service: Service = pictor::create_service_test(service_name, ts.ctx());
                
        let content = string::utf8(b"checker1");       
        let user_id = 1;
        let device_id = string::utf8(b"00330-81486-23222-AA048");
                                
        let checker_id = service.create_new_checker(owner, content, user_id, device_id, ts.ctx());
        
        //remove job
        service.remove_checker_test(checker_id);

        //verify job
        let is_exists = service.is_checker_exists(checker_id);

        assert!(!is_exists, 3);
        
        transfer::public_transfer(service, owner);
        
    };

    ts::end(ts);

}

#[test]
fun test_update_checker_status() {
    
    let owner = @0xA;
    let mut ts = ts::begin(owner);
    
    ts::next_tx(&mut ts, owner);
        
    let service_name = string::utf8(b"PictorJobService");
    let mut service: Service = pictor::create_service_test(service_name, ts.ctx());
            
    let content = string::utf8(b"checker1");       
    let user_id = 1;
    let device_id = string::utf8(b"00330-81486-23222-AA048");
    let status = 5;

    let checker_id = service.create_new_checker(owner, content, user_id, device_id, ts.ctx());
    
    //update job status to 5
    service.set_checker_status(checker_id, status);
    
    //verify    
    let worker_status = service.get_checker_status(checker_id);
        
    assert!(worker_status == status , 4);
        
    transfer::public_transfer(service, owner);

    ts::end(ts);

}
