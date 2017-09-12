#include "Timer.h"
#include "Beacon.h"
#include "printf.h"

module BeaconC{
	uses interface Boot;
	uses interface Timer<TMilli> as Timer0;
	uses interface Read<uint16_t>;
	uses interface SplitControl as AMControl;
	uses interface Packet as AMPacket;	
	uses interface AMSend;
}

implementation{
	message_t pkt;
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
		call Read.read();
		}
///////////////////////////////////////////////////////////////////
	event void Read.readDone(error_t err, uint16_t val) {

		if(err== SUCCESS&& !SendBusy) {
 			BaseStationMsg* payload= (BaseStationMsg*)call AMPacket.getPayload(&pkt,sizeof(BaseStationMsg));
		

			if(payload== NULL) {
				return;
				}
			if(sizeof(payload)> call AMPacket.maxPayloadLength()) {
				return; 
				}
				// Powered by USB : -40.1 + 0.01 * val;
				// Powered by 2 AA Batteries : -39.6 + 0.01 * val
			payload->sensor_No= -40.1 + 0.01 * val;
			if(call AMSend.send(1,&pkt,sizeof(BaseStationMsg))== SUCCESS) {
 				SendBusy = TRUE;
 				}
 			}
 		}

	event void AMSend.sendDone(message_t* msg, error_t err) {
		if(msg== &pkt) {
 			SendBusy = FALSE;
 			}
 		}
}


