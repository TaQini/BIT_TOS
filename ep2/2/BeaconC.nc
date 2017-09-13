// Sensor 2
// recvie Random Number from 0 
// send random num + sensor_id to 3
#include "Timer.h"
#include "Beacon.h"
#include "printf.h"

module BeaconC{
	uses interface Boot;
	uses interface Timer<TMilli> as Timer0;	
	uses interface SplitControl as AMControl;
	uses interface Packet as AMPacket;
	uses interface AMSend;
	uses interface Receive as AMReceive;
}

implementation{
	message_t pkt;
	bool SendBusy=FALSE;
	bool NewPkt = FALSE; // if there r NO new pkt, stop sending data
	nx_uint8_t random;

	////////
	// int debug = 100;
	///////

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
		if(NewPkt){
			BaseStationMsg* SendMsg=(BaseStationMsg*)call AMSend.getPayload(&pkt,sizeof(BaseStationMsg));
			
			SendMsg->data = random;
			SendMsg->sensor_No = TOS_NODE_ID; 
			
			// sent pkt to 3
			if(call AMSend.send(3,&pkt,sizeof(BaseStationMsg))!=SUCCESS){
				SendBusy=FALSE;
			}
			else{ // Success
				SendBusy=TRUE;
				NewPkt = FALSE;
			}
		}
	}

	event void AMSend.sendDone(message_t* msg,error_t err){
		if(&pkt==msg){
			SendBusy=FALSE;
		}
	}

	event message_t* AMReceive.receive(message_t* msg, void* payload, uint8_t len){
	if (len == sizeof(RandMsg)) { 
    	RandMsg* btrpkt = (RandMsg*)payload;
    	random = btrpkt->random; // use local var to stroage SN from 0
		NewPkt = TRUE; // when sensor 1,2 receive a pkt successfully, set NewPkt to TRUE
  //   	printf("%s\n", "///////////////////////////");
  //   	printf("[%d] %d \n", debug, random);
  //   	printf("%s\n", "///////////////////////////");
		// debug ++;
    }
    return msg;
  }
}
