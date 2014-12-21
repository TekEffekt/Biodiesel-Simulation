//
//  SimulationModified.h
//  BiodieselSimulation
//
//  Created by rileyd on 10/6/14.
//
//

#ifndef __BiodieselSimulation__SimulationModified__
#define __BiodieselSimulation__SimulationModified__

#include <stdio.h>
#import "TheSimulation.h"

#endif /* defined(__BiodieselSimulation__SimulationModified__) */
//
//  TheSimulation.m
//  TheWater
//
//  Copyright (c) 2013 University of Wisconsin Parkside. All rights reserved.
//  Written by Xiaowei Zhang and Derek Riley
//
// ====================================Theoretical basis======================================
// probabilistic berification of a Biodiesel Production System Using Statistical Model Checking
// Stochastic Hybrid System (SHS): model discrete, continuous,
// and stochastic dynamics of a biodiesel reactor.
// TG: triglycerides
// DG: diglycerides
// MG: monoglycerides
// E: methylesters (biodiesel)
// M: methanol
// GL: glycerol
// T: temperature
// TG + M -> DG + E
// DG + E -> TG + M
// DG + M -> MG + E
// MG + E -> DG + M
// MG + M -> GL + E
// GL + E -> MG + M
// ===========================================================================================

//DDR: UI
int initOil;
int initMethanol;
int initCatalyst;
int initTemperature;
int timetoreact;
int timetosettle;
int initSimLength;

//DDR: COMPUTATION (INIT)
int emormm=2;
float length;//set by user
int indviter=1;//num of sims
int p=5;
double stepsize=.02;
double L1=-11;
double L2=-10;
double L3=-9;
int dim=7;//number of chemical species
int dimn=6;//number of chemical reactions
long double k[25];//kinetic coefficients (N) N=number of reactions, D= number of reactants
int rxns[25][40];//reactions (DxN)
long double cx[25];//current x vals (D)
long double cxL1[25];//current x vals (D)
long double cxL2[25];//current x vals (D)
long double cxL3[25];//current x vals (D)
long double dx[25];//difference x vals (D)
long double W[40];//W noise vals (N)
long double E[40];//E noise vals (N)
long double mu[40];//mu noise vals (N)
long double I[40][40];//I noise (NxN)
long double eta[40][20];//eta noise (NxP)
long double ol[40][20];//ol noise (NxP)
long double rates[40];//reaction rates (N)
int rateloc[40][2];//location of reaction rates (Nx#ofreactantsallowed)
long double newrate[40][25];//for derivative calc (NxD)
long double leftover[40][25];//for derivative calc (NxD)
int countsteps,countsteps2,ratecount;
double timecount;
int u;
long double rx1,rx2,pp,U,randerr;
long double sigsum;
//	double lambda=.05;
double fails=0;
double influence;
double tempnanval;
int level=0;
int hypothesis=0;
int reloaded=0;
double L1time,L2time,L3time;
int L1left=0;
int L2left=0;
int L3left=0;
long double minval;
int phitnum=0;
int mode=0;
int savedmode=0;
double rereact=0;
double totrereact=0;

//	double hypthresh=0.99;
float reactiontime=0;

float TGout;
float DGout;
float MGout;
float Mout;
float Eout;
float Convout;
float Costs;

int simInitOil=5;
int simInitMethanol=40;
int simInitCatalyst=5;
int simInitTemperature=40;
int simInitMixLength=5;
int simInitSettleLength=5;

@implementation TheSimulation

//DDR: Computation and UI initialization
-(void)initDataWith:(float)oil methanol:(float)methanol catalyst:(float)catalyst temperature:(float)temperature mixingLength:(float)mixingLength andSettlingTime:(float)settlingTime
{
    initOil = oil;
    initMethanol = methanol;
    initCatalyst = catalyst;
    initTemperature = temperature;
    timetoreact = mixingLength;
    timetosettle = settlingTime;
    
    initSimLength = timetoreact+timetosettle;
    length = initSimLength;
    simInitOil=initOil;
    simInitMethanol=initMethanol;
    simInitCatalyst=initCatalyst;
    simInitTemperature=initTemperature;
    simInitMixLength=timetoreact;
    simInitSettleLength=timetosettle;
    
    {
        rxns[1][1]=-1;
        rxns[2][1]=1;
        rxns[3][1]=0;
        rxns[4][1]=1;
        rxns[5][1]=-1;
        rxns[6][1]=0;
        rxns[7][1]=0;
        rxns[1][2]=1;
        rxns[2][2]=-1;
        rxns[3][2]=0;
        rxns[4][2]=-1;
        rxns[5][2]=1;
        rxns[6][2]=0,
        rxns[7][2]=0;
        rxns[1][3]=0;
        rxns[2][3]=-1;
        rxns[3][3]=1;
        rxns[4][3]=1;
        rxns[5][3]=-1;
        rxns[6][3]=0;
        rxns[7][3]=0;
        rxns[1][4]=0;
        rxns[2][4]=1;
        rxns[3][4]=-1;
        rxns[4][4]=-1;
        rxns[5][4]=1;
        rxns[6][4]=0;
        rxns[7][4]=0;
        rxns[1][5]=0;
        rxns[2][5]=0;
        rxns[3][5]=-1;
        rxns[4][5]=1;
        rxns[5][5]=-1;
        rxns[6][5]=1;
        rxns[7][5]=0;
        rxns[1][6]=0;
        rxns[2][6]=0;
        rxns[3][6]=1;
        rxns[4][6]=-1;
        rxns[5][6]=1;
        rxns[6][6]=-1;
        rxns[7][6]=0;
    }
    pp=0;
    for(int r=1;r<=p;r++){pp-=1/r/r;}//pp initialization
    pp*=1/2/3.14152/3.14152;
    pp+=1/12;
    U=rand();
    U/=RAND_MAX;
}

-(void)setup
{//calculate the reaction results, and determine whether the reaction was successful
    //algorithm for calculating "cost per gallon"
    
    Costs = ((initTemperature/1050 - 0.012)*initSimLength + initMethanol/5)/initOil;
    if(Costs<0)Costs=0.01;
    //    Costs = ((initTemperature/1050.0)*initSimLength + initMethanol/5)/initOil;
    
    for(int kay=0;kay<indviter;kay++){//controls the number of times the simulation is run
        countsteps=1;
        countsteps2=1;
        u=1;
        mode=savedmode;
        minval = 100000;
        level=0;
        mode=0;
        //initial conditions
        cx[1]=initOil;//TG
        cx[2]=.0000001;//DG
        cx[3]=.0000001;//MG
        cx[4]=.0000001;//E
        cx[5]=initMethanol;//M (9 units required, 18 units typically used)
        cx[6]=.000001;//Gl
        cx[7]=20;//Temp
        timecount=0;
        influence=1;
        rereact=0;
        
        
        //        if(request.notRunBefore()){
        //[self schedule:@selector(Loop) interval:stepsize];
        //        }
        //        else{
        //          present results and ask user to select another configuration
        //        }
        
    }
}

- (NSDictionary*)getTheResult
{
    // The convout is converted here to a full decimal number
      return @{@"TGout": [NSNumber numberWithFloat:TGout], @"DGout": [NSNumber numberWithFloat:DGout],
                        @"MGout": [NSNumber numberWithFloat:MGout], @"Eout": [NSNumber numberWithFloat:Eout],
                        @"Convout": [NSNumber numberWithFloat:Convout * 100], @"Cost":
               [NSNumber numberWithFloat:Costs], @"mode": [NSNumber numberWithFloat:mode],
               @"rereact":[NSNumber numberWithFloat:rereact]};
}

-(bool)loop
{
    //DDR: Computations
    bool simulationNotDone = YES;
    
    if (timecount<(timetoreact+timetosettle)){
        static double lastTimeTargetAdded = 0;
        double now = [[NSDate date] timeIntervalSince1970];
        if(lastTimeTargetAdded == 0 || now - lastTimeTargetAdded >= 0 ) {
            lastTimeTargetAdded = now;
            
            //reaction rate calculations
            k[1]=39180000.0*exp(-13145.0/1.987/(cx[7]+273.0))*cx[1]*cx[5];
            k[2]=577400.0*exp(-9932.0/1.987/(cx[7]+273.0))*cx[2]*cx[4];
            k[3]=5888.0*exp(-19860.0/1.987/(cx[7]+273.0))*1000000000*cx[2]*cx[5];
            k[4]=98658.0*exp(-14639.0/1.987/(cx[7]+273.0))*100000*cx[3]*cx[4];
            k[5]=5350.0*exp(-6421.0/1.987/(cx[7]+273.0))*cx[3]*cx[5];
            k[6]=21500.0*exp(-9588.0/1.987/(cx[7]+273.0))*cx[4]*cx[6];
            if(mode == 0){//temp switching, normal reactions
                if(cx[7]>initTemperature){k[7]=-0.01*cx[7];}
                else{k[7]=0.02*(300-cx[7]);}
                if(timecount>timetoreact){//***replace timetoreact with slider bar input
                    mode=1;//switch to mode 1 after a certain amount of time
                }
            }
            else if(mode == 1){//settling (no heating)
                k[7]=-0.0001*cx[7];//heat off
            }
            
            sigsum=0;
            for(int nnn=1;nnn<=dimn;nnn+=2){//generating W+E noise vector
                rx1=rand();rx1/=RAND_MAX;
                rx2=rand();rx2/=RAND_MAX;
                if(rx1==0){rx1=0.000000000001;}
                if(rx2==0){rx2=0.000000000001;}
                W[nnn]=sqrt(-2*log(rx1))*cos(2*3.1415*rx2);
                W[nnn+1]=sqrt(-2*log(rx1))*sin(2*3.1415*rx2);
                W[nnn]*=sqrt(stepsize);
                W[nnn+1]*=sqrt(stepsize);
            }
            for(int n=1;n<=dimn;n++){//reaction rate calculations
                rates[n]=1;
                ratecount=0;
                for(int d=1;d<=dim;d++){//find reactant(s)
                    if(rxns[d][n]==-1){//consuming
                        rates[n]*=cx[d];
                        newrate[n][d]=cx[d];
                        ratecount++;
                        rateloc[n][ratecount]=d;
                    }
                    else{
                        newrate[n][d]=0;
                        leftover[n][d]=0;
                    }
                }
                for(int d=1;d<=dim;d++){
                    if(rxns[d][n]==-1&&ratecount==1){leftover[n][d]=1;}
                    if(rxns[d][n]==-1&&(ratecount==2||ratecount==0)){
                        if(ratecount==2){leftover[n][d]=cx[rateloc[n][1]];ratecount=0;}
                        else{leftover[n][d]=cx[rateloc[n][0]];}
                    }
                }
            }
            
            for(int d=1;d<=dim;d++){
                dx[d]=0;
                for(int n=1;n<=dimn;n++){
                    dx[d]+=stepsize*rxns[d][n]*k[n]+rxns[d][n]*sqrt(k[n])*0.0001*W[n];
                }
            }
            dx[7]=stepsize*k[7]+.05*W[1];//temp calculations
            //milstein calculations
            if(emormm==2){
                for(int n=1;n<=dimn;n+=2){//calculate noise variables required
                    rx1=rand();rx1/=RAND_MAX;
                    rx2=rand();rx2/=RAND_MAX;
                    if(rx1==0){rx1=0.000000000001;}//printf("incval1a\n");}
                    if(rx2==0){rx2=0.000000000001;}//printf("incval1b\n");}
                    mu[n]=sqrt(-2*log(rx1))*cos(2*3.1415*rx2);
                    mu[n+1]=sqrt(-2*log(rx1))*sin(2*3.1415*rx2);
                    for(int r=0;r<p;r++){
                        rx1=rand();rx1/=RAND_MAX;
                        rx2=rand();rx2/=RAND_MAX;
                        if(rx1==0){rx1=0.000000000001;}//printf("incval2a\n");}
                        if(rx2==0){rx2=0.000000000001;}//printf("incval2b\n");}
                        eta[n][r]=sqrt(-2*log(rx1))*cos(2*3.1415*rx2);
                        eta[n+1][r]=sqrt(-2*log(rx1))*sin(2*3.1415*rx2);
                        rx1=rand();rx1/=RAND_MAX;
                        rx2=rand();rx2/=RAND_MAX;
                        if(rx1==0){rx1=0.000000000001;}//printf("incval3a\n");}
                        if(rx2==0){rx2=0.000000000001;}//printf("incval3b\n");}
                        ol[n][r]=sqrt(-2*log(rx1))*cos(2*3.1415*rx2);
                        ol[n+1][r]=sqrt(-2*log(rx1))*sin(2*3.1415*rx2);
                    }
                }
                for(int n1=1;n1<=dimn;n1++){//calculate I values
                    for(int n2=1;n2<=dimn;n2++){
                        I[n1][n2]=0;
                    }
                }
                for(int n1=1;n1<=dimn;n1++){//calculate I values
                    for(int n2=1;n2<=dimn;n2++){
                        for(int r=0;r<p;r++){//p=20
                            tempnanval=1/(r+1)*(eta[n1][r]*(sqrt(2)*E[n2]+ol[n2][r])-eta[n2][r]*(sqrt(2)*E[n1]+ol[n1][r]));
                            
                        }
                        
                        
                        I[n1][n2]*=stepsize/2/3.1415;
                        I[n1][n2]+=stepsize*(.5*E[n1]*E[n2]+sqrt(pp)*(mu[n1]*E[n2]-mu[n2]*E[n1]));
                    }
                }
                for(int n=1;n<=dimn;n++){
                    I[n][n]=.5*(W[n]*W[n]-stepsize);
                }//diagonal simplification
                for(int d=1;d<dim;d++){//adjusted iterations to skip dx[7]
                    double milsum=0;
                    for(int n1=1;n1<=dimn;n1++){
                        for(int n2=1;n2<=dimn;n2++){
                            for(int d2=1;d2<=dim;d2++){//derivative wrt d2
                                if(leftover[n1][d2]!=0){//change to >0???
                                    tempnanval=rxns[d2][n1]*sqrt(k[n1])*rxns[d][n2]/sqrt(newrate[n1][d2])/2*sqrt(k[n2]*leftover[n1][d2])*I[n1][n2];//b*der(b)*I
                                }
                                else{milsum+=0;}
                            }
                        }
                    }
                    dx[d]+=.5*milsum;//add in the milstien term
                }
            }
            for(int d=1;d<=dim;d++){//reflective boundaries
                if((cx[d]+dx[d]<=0)&& (dx[d]<0)){cx[d]=0.000000001;}//-=dx[d];
                else {cx[d]+=dx[d];}
            }
            if(cx[6]>.00005 && mode==1){cx[6]=.0000001;}//settling dynamics
            if(mode==2){//adding methanol in mode 2, resetting time
                cx[5]+=1;mode=0;reactiontime+=timecount;timecount=0;
                //				printf("ID:%d rereacting rate=%f\n",id,cx[4]/(cx[4]+cx[3]+cx[2]+cx[1]));
            }
            timecount+=stepsize;
            //RESULTS
            TGout = cx[1];
            DGout = cx[2];
            MGout = cx[3];
            Mout = cx[5];
            Eout = cx[4];
            Convout = cx[4]/(cx[4]+cx[1]+cx[2]+cx[3]);
            
            NSLog(@"The triglycerides: %f", TGout);
            NSLog(@"The diglycerides: %f", DGout);
            NSLog(@"The monoglycerides: %f", MGout);
            NSLog(@"The biodiesl: %f", Eout);
            NSLog(@"The conversion rate: %f", Convout);
            NSLog(@"END LOOP");
        }
    } else
    {
        simulationNotDone = NO;
    }
    return simulationNotDone;
}

@end
