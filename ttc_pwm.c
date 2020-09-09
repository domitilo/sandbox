/*
 * ttc_pwm.c
 *
 *  Created on: 16 ago. 2020
 *      Author: Adri
 */


#include <stdio.h>
#include <stdlib.h>
#include "xparameters.h"
#include "xttcps.h"

typedef struct {
	u32 OutputHz;	/* Output frequency */
	XInterval Interval;	/* Interval value */
	u8 Prescaler;	/* Prescaler value */
	u16 Options;	/* Option settings */
} TimerSetupType;

//TimerSetupType 	  *Pwm_settings;
TimerSetupType Pwm_settings =	{1, 0, 0, 0} ;/* PWM timer counter initial setup, only output freq */


XTtcPs_Config *Pwm_config;
XTtcPs 	      *Pwm_instance;
#define PWM_DEVICE_ID XPAR_PS7_TTC_0_DEVICE_ID

const int PWM_DEVICES[XPAR_XTTCPS_NUM_INSTANCES] = {  XPAR_PS7_TTC_0_DEVICE_ID, XPAR_PS7_TTC_1_DEVICE_ID, XPAR_PS7_TTC_2_DEVICE_ID};


int setup_pwm(u32 TTC_ID, u32 Freq, u8 Duty);
//int setup_pwm(void);

void main(){

	//setup_pwm2();
	//setup_pwm(	PWM_DEVICES[0], 1, );
	for (int color = 0; color < 3; ++color) {
		setup_pwm(	PWM_DEVICES[color], 1,33*color);
	}

}



int setup_pwm(u32 TTC_ID, u32 Freq, u8 Duty){

//	typedef struct {
//		u32 OutputHz;	/* Output frequency */
//		XInterval Interval;	/* Interval value */
//		u8 Prescaler;	/* Prescaler value */
//		u16 Options;	/* Option settings */
//	} TimerSetupType;
	TimerSetupType *TTC_Setup;
	XTtcPs_Config *Pwm_config;
	XTtcPs *TTC_Inst;
	XMatchRegValue Match_value = 0;
	int Status = XST_SUCCESS;


	//TTC_Setup = &(Pwm_settings);

	TTC_Setup->OutputHz = Freq;
	TTC_Setup->Options =( XTTCPS_OPTION_INTERVAL_MODE |
						   XTTCPS_OPTION_MATCH_MODE);

	Pwm_config = XTtcPs_LookupConfig(TTC_ID);
	if (NULL == Pwm_config) {
		return XST_FAILURE;
	}

	Status = XTtcPs_CfgInitialize(TTC_Inst, Pwm_config, Pwm_config->BaseAddress);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}
	XTtcPs_SetOptions(TTC_Inst, TTC_Setup->Options);

	XTtcPs_CalcIntervalFromFreq(TTC_Inst, TTC_Setup->OutputHz,
		&(TTC_Setup->Interval), &(TTC_Setup->Prescaler));

	if ( TTC_Setup->Interval == 0xFFFF || TTC_Setup->Prescaler == 0xFF ) {
		return XST_FAILURE;
	}
	XTtcPs_SetInterval(TTC_Inst, TTC_Setup->Interval);
	XTtcPs_SetPrescaler(TTC_Inst, TTC_Setup->Prescaler);


	Match_value = Duty*TTC_Setup->Interval/100;
	XTtcPs_SetMatchValue(TTC_Inst, 0, Match_value);

	XTtcPs_Start(TTC_Inst);

	return Status;
}


int setup_pwm2(){
	int Status = XST_SUCCESS;
	short DutyCycle_RGB[3] = {20,33,33};
	XTtcPs 	      *Timer;
	XMatchRegValue Match_value = 0;
	TimerSetupType *TimerSetup;
	TimerSetup = &(Pwm_settings);

	Timer = &(Pwm_instance);

	TimerSetup->Options |=( XTTCPS_OPTION_INTERVAL_MODE |
		      	  	  	  	  XTTCPS_OPTION_MATCH_MODE);
for (int color = 0; color < 3; ++color) {


//	XTtcPs_Config *Config;
	/* Setup Timer */
	//Pwm_config = XTtcPs_LookupConfig(PWM_DEVICE_ID);
	Pwm_config = XTtcPs_LookupConfig(PWM_DEVICES[color]);
	if (NULL == Pwm_config) {
		return XST_FAILURE;
	}

	/*
	 * Initialize the device
	 */
	Status = XTtcPs_CfgInitialize(Timer, Pwm_config, Pwm_config->BaseAddress);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Set the options
	 */
	XTtcPs_SetOptions(Timer, TimerSetup->Options);
	/*
	 * Timer frequency is preset in the TimerSetup structure,
	 * however, the value is not reflected in its other fields, such as
	 * IntervalValue and PrescalerValue. The following call will map the
	 * frequency to the interval and prescaler values.
	 */
	XTtcPs_CalcIntervalFromFreq(Timer, TimerSetup->OutputHz,
		&(TimerSetup->Interval), &(TimerSetup->Prescaler));

	/*
	 * Set the interval and prescale
	 */
	XTtcPs_SetInterval(Timer, TimerSetup->Interval);
	XTtcPs_SetPrescaler(Timer, TimerSetup->Prescaler);

	//for (u8 rgb = 0; rgb < 3; ++rgb) {
		Match_value = DutyCycle_RGB[color]*TimerSetup->Interval/100;
		XTtcPs_SetMatchValue(Timer, 0, Match_value);
	//}



	XTtcPs_Start(Timer);
}

	return XST_SUCCESS;
}








