// Snosor 3 
// Recv msg from 1,2
#include "Timer.h"
#include "Beacon.h"
#include "printf.h"

module BaseStationC{
	uses interface Boot;
	
	uses interface SplitControl as AMControl;
	uses interface Packet as AMPacket;	
	uses interface Receive as AMReceive;
}

implementation{
	message_t pkt;

	/////////////
	int debug = 1;
	char debug_msg[] = "[temp]";
	/////////////

	event void Boot.booted(){
		call AMControl.start();
	}
	
	event void AMControl.startDone(error_t err){
		if(err!=SUCCESS){
			call AMControl.start();
		}
	}
	
	event void AMControl.stopDone(error_t err){}
	
	event message_t* AMReceive.receive(message_t* msg,void* p,uint8_t len){
		if(len==sizeof(BaseStationMsg)){
			BaseStationMsg* receiveMsg=(BaseStationMsg*)p;

			if (receiveMsg->sensor_No == 2){
				debug_msg[1] = 'r';
				debug_msg[2] = 'a';
				debug_msg[3] = 'n';
				debug_msg[4] = 'd';
			}
			
			printf("///[%d]//%s//////////////\n",debug++,debug_msg);
			printf("data: %d\n",receiveMsg->data);
			printf("sensor_No: %d\n",receiveMsg->sensor_No);
			printf("/////////////////////////////\n\n");
			printfflush();
		}
		return msg;
	}	
}