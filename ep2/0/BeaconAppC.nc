#include "Beacon.h"

configuration BeaconAppC{}

implementation{
	components BeaconC,MainC;
	components new TimerMilliC() as Timer0;

	components ActiveMessageC;
	components new AMSenderC(AM_BEACON);
	
	BeaconC.Boot->MainC;

	BeaconC.Timer0->Timer0;
	
	BeaconC.AMPacket->ActiveMessageC;	
	BeaconC.AMControl->ActiveMessageC;
	BeaconC.AMSend->AMSenderC;

	// random
	components RandomC;
	BeaconC.Random -> RandomC;

	// temper
	components new SensirionSht11C() as Sense;
	BeaconC.Read-> Sense.Temperature;
}
