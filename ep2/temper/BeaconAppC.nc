#include "Beacon.h"

configuration BeaconAppC{}

implementation{
	components BeaconC,MainC;
	components new TimerMilliC() as Timer0;

	components new SensirionSht11C() as Sense;//peizhi wendu zujian
	components ActiveMessageC;
	components new AMSenderC(AM_BEACON);
	
	BeaconC.Boot->MainC;

	BeaconC.Timer0->Timer0;
	BeaconC.Read-> Sense.Temperature;
	BeaconC.AMPacket->ActiveMessageC;	
	BeaconC.AMControl->ActiveMessageC;
	BeaconC.AMSend->AMSenderC;






 
}
