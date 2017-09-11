#ifndef BEACON_H
#define BEACON_H

#include <AM.h>

enum{
	AM_BEACON=0xC8,
	TIMER_PERIOD_MILLI=1000	
};

typedef nx_struct TemperMsg{
	nx_uint8_t temper;
}TemperMsg;

typedef nx_struct RandMsg{
	nx_uint8_t random;
	nx_uint16_t padding; // let len(BeaconMsg) != len(RandMsg)
}RandMsg;

typedef nx_struct BaseStationMsg{
	nx_uint8_t data;
	nx_uint8_t sensor_No;
}BaseStationMsg;

#endif
