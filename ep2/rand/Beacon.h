#ifndef BEACON_H
#define BEACON_H

#include <AM.h>

enum{
	AM_BEACON=0xC8,
	TIMER_PERIOD_MILLI=1000	
};

typedef nx_struct BeaconMsg{
	nx_uint8_t pkt_No;
}BeaconMsg;

typedef nx_struct BaseStationMsg{
	nx_uint8_t pkt_No;
	nx_uint8_t sensor_No;
}BaseStationMsg;

#endif
