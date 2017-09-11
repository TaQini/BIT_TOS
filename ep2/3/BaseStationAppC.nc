#include "Beacon.h"

configuration BeaconAppC{}

implementation{
	components BaseStationC,MainC;
	
	components ActiveMessageC;
	components new AMReceiverC(AM_BEACON);
	
	BaseStationC.Boot->MainC;	
	
	BaseStationC.AMPacket->ActiveMessageC;	
	BaseStationC.AMControl->ActiveMessageC;
	BaseStationC.AMReceive->AMReceiverC;
}
