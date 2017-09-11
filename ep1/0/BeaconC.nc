#include "Timer.h"
#include "Beacon.h"
#include "printf.h"

module BeaconC{
	uses interface Boot;
	uses interface Timer<TMilli> as Timer0;
	
	uses interface SplitControl as AMControl;
	uses interface Packet as AMPacket;	
	uses interface AMSend;
}

implementation{
	message_t pkt;
	size_t cnt = 1;
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
			BeaconMsg* SendMsg=(BeaconMsg*)call AMSend.getPayload(&pkt,sizeof(BeaconMsg));
			
			SendMsg->pkt_No = cnt;
			
			if(call AMSend.send(AM_BROADCAST_ADDR,&pkt,sizeof(BeaconMsg))!=SUCCESS){
				SendBusy=FALSE;
			}
			else{
				SendBusy=TRUE;
				cnt += 1;
			}		
		}
	}

	event void AMSend.sendDone(message_t* msg,error_t err){
		if(&pkt==msg){
			SendBusy=FALSE;
		}
	}
}
