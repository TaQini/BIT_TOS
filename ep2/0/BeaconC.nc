#include "Timer.h"
#include "Beacon.h"
#include "printf.h"

module BeaconC{
	uses interface Boot;
	uses interface Timer<TMilli> as Timer0;
	
	uses interface SplitControl as AMControl;
	uses interface Packet as AMPacket;	
	uses interface AMSend;

	uses interface Random;

	uses interface Read<uint16_t>;
}

implementation{
	message_t pkt; 
	size_t cnt = 1; // the increasing serial number
	bool SendBusy=FALSE;
	
	event void Boot.booted(){
		call AMControl.start();
	}
	
	event void AMControl.startDone(error_t err){
		if(err!=SUCCESS){
			call AMControl.start();
		}
		else{
			call Timer0.startPeriodic(TIMER_PERIOD_MILLI);
		}
	}
	
	event void AMControl.stopDone(error_t err){}

	event void Timer0.fired(){
		if (cnt <= 60){ 
			call Read.read();
		}
		else if (cnt <= 120){
			RandMsg* SendMsg=(RandMsg*)call AMSend.getPayload(&pkt,sizeof(RandMsg));
			
			SendMsg->random = call Random.rand16()%100; 
			SendMsg->padding = 0x29a;

			if(call AMSend.send(AM_BROADCAST_ADDR,&pkt,sizeof(RandMsg))!=SUCCESS){
				SendBusy=FALSE;
			}
			else{ // Success
				SendBusy=TRUE;
				cnt += 1; // increase cnt
			}			
		}
	}

	event void Read.readDone(error_t err, uint16_t val) {
		if( err == SUCCESS && !SendBusy) {
 			TemperMsg* payload= (TemperMsg*)call AMPacket.getPayload(&pkt,sizeof(TemperMsg));	
 			
			if(payload== NULL) {
				return;
			}
			if(sizeof(payload)> call AMPacket.maxPayloadLength()) {
				return; 
			}
			// Powered by USB : -40.1 + 0.01 * val;
			// Powered by 2 AA Batteries : -39.6 + 0.01 * val
			payload->temper = -40.1 + 0.01 * val;

			if(call AMSend.send(AM_BROADCAST_ADDR,&pkt,sizeof(TemperMsg))!= SUCCESS) {
 				SendBusy = FALSE;
 			}
 			else{ // Success
 				SendBusy = TRUE;
				cnt += 1; // increase cnt
 			}
		}
	}

	event void AMSend.sendDone(message_t* msg,error_t err){
		if(&pkt == msg){
			SendBusy=FALSE;
		}
	}
}
