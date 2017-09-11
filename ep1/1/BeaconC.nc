// Sensor 1
// recvie 2 msg 
// send msg+sensor_id to 0
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
	bool NewPkt = FALSE; // if No new pkt, then do not send data

	nx_uint8_t pkt_No;
	
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
		if( (!((pkt_No ^ TOS_NODE_ID) & 1)) && NewPkt){
			// when pkt_no and sennor_No are both odd or even, send the pkt
			BaseStationMsg* SendMsg=(BaseStationMsg*)call AMSend.getPayload(&pkt,sizeof(BaseStationMsg));
			
			// set pkt_No and sensor_No  
			SendMsg->pkt_No = pkt_No;
			SendMsg->sensor_No = TOS_NODE_ID; 
			
			// sent pkt to 3
			if(call AMSend.send(3,&pkt,sizeof(BaseStationMsg))!=SUCCESS){
				SendBusy=FALSE; 
			}
			else{
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
	if (len == sizeof(BeaconMsg)) {
    	BeaconMsg* btrpkt = (BeaconMsg*)payload;
    	pkt_No = btrpkt->pkt_No;
		NewPkt = TRUE;
    }


    return msg;
  }
}