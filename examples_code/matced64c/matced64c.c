/*
** matced64c.c interface library for Matlab
   64 bit compatible version
** original by Dario Ringach
** modified for 32bit and 64 bit by JG Colebatch 
   12.2013: 64 bit compatible version from matced32.c
   02.2016: Fixed address calculations in cedToHost and cedTo1401. TDB
*/

#include <windows.h>
#include <stdio.h>
#include <string.h>
#include "c:\Program Files\Matlab\R2012b\extern\include\mex.h"  
#include "c:\use1432_64\use1401.h"  //23.11.2013 version and .lib

#define BUF_SIZE 32000  // May 06, close to 32K

static short sHand = -1;
static void *tf_pr[7];  //pointers to Transfer Areas

static void FreeTFMemory(void)
// exit routine to ensure transfer memory is freed
{
	short i;

	for (i=0;i<=7;i++)
		if(tf_pr[i])
		{
          mxFree(tf_pr[i]);
		  tf_pr[i]=0;
		}
}

void cedOpen()
{
    short code;
                                                         
    if (sHand < 0)                     /* avoid opening twice */ 
 {                                                    
    code = U14Open1401(0);              /* open 1401+ */                 
    if (code < 0)                       /* check for success */
    {
        mexPrintf("Could not open CED 1401 - Code = %d \n\n",code);
        sHand = -1;
    } 
    else
    {
        mexPrintf("CED-1401 Initialized!\n");
        sHand = code;               /* Save the 1401 handle */
    }
  } 
  else mexPrintf("CED-1401 already opened \n");
}     

void cedOpenX(plhs,nrhs,prhs)
//returns copy of handle
// ver 3 - allows no of 1401 to be specified, default=0
int nrhs;
mxArray *plhs[];
const mxArray *prhs[];
{
 double *pr;
 short num1401;
            
    if (nrhs < 2)
	{
		num1401=0;
	}
	else
	{
      pr=mxGetPr(prhs[1]);
	  num1401=(short)*pr;  
	}
    if (sHand < 0)
    {
    sHand = U14Open1401(num1401); /* open specified or default 1401 */                 
    }
    else
    {
    mexPrintf("CED-1401 already opened \n");
    }
    plhs[0]=mxCreateDoubleMatrix(1,1,mxREAL);  
    pr = mxGetPr(plhs[0]);
    *pr = (double)sHand;
}               

void cedToHost(plhs,nrhs,prhs)
mxArray *plhs[];
int nrhs;
const mxArray *prhs[];
{
    double*     pr;
    int         length;  //no longer 64K limit
    DWORD       address;
	DWORD       offset;
	unsigned short toRead;
    unsigned short n; //
    short       code;
    short       data[BUF_SIZE];   /* data buffer */

    if (nrhs<3)
    {
        mexPrintf("Not enough parameters: need length and start address...\n");
        return;
    }

    if (sHand < 0)
    {
        mexPrintf("1401 not opened for use\n");
        return;
    }

    pr = mxGetPr(prhs[1]);    /* get length */
    length = (int) *pr;
	if (length < 0) {
      printf("Cannot make an array this big in Matlab");
      return;
	}
	pr = mxGetPr(prhs[2]);	   /* get address */
    address = (DWORD) *pr; 
    if (length>BUF_SIZE)
		toRead = BUF_SIZE;
	else
		toRead = (unsigned short)length;
    
    plhs[0] = mxCreateDoubleMatrix(1, length, mxREAL);  // note implicit size limit in Matlab
    pr = mxGetPr(plhs[0]);
    offset=0;

    while(length > 0) 
    { 
        code = U14ToHost(sHand, (LPSTR) &data[0], 2*toRead, (DWORD)(address+(2*offset)), 0);
        if (code != U14ERR_NOERROR)
        {
            mexPrintf("Could not execute U14ToHost() - code=%d\n",code);  // give error code
            return;
        }

        for (n=0;n<toRead;n++) 
            *pr++ = (double) data[n];
        length = length-toRead;
        offset = offset+toRead;  
        if (length > BUF_SIZE)
            toRead = BUF_SIZE;
        else
            toRead = (unsigned short)length; 
	} // while
}

void cedTo1401(nrhs,prhs)
int nrhs;
const mxArray *prhs[];
{
    double *pr;
    int length;                                 // limit set by Matlab
    DWORD address;                              // need to access full range of addresses
	DWORD offset;
	unsigned short toSend;
    int n;
    short code;
    short data[BUF_SIZE];                       // data buffer

    if(nrhs<3) {
      mexPrintf("Not enough parameters: need length, start address, and array.\n");
      return;
    }

    if (sHand < 0)
    {
        mexPrintf("1401 not opened for use\n");
        return;
    }

    pr = mxGetPr(prhs[1]);                      // get length
    length = (int) *pr;                         // limit is set by Matlab as far as I can tell.
    if (length > BUF_SIZE)
        toSend = BUF_SIZE;
	else
		toSend = (unsigned short)length;

    pr = mxGetPr(prhs[2]);	                    // get address
    address = (DWORD) *pr;
	
    pr = mxGetPr(prhs[3]);                      // get array pointer
   
	offset = 0;
    while (length > 0) 
	{
        for (n=0;n<toSend;n++)
            data[n] = (short) *pr++;            // pr just increments throughout
        code = U14To1401(sHand, (LPSTR) &data[0], 2*toSend, (DWORD)(address+(2*offset)), 0);
        if (code != U14ERR_NOERROR)
        {
            mexPrintf("Could not execute U14To1401()- code=%d\n",code);  // give error code
            return;
        }
        offset = offset+toSend;
        length = length-toSend;
        if (length > BUF_SIZE)
            toSend = BUF_SIZE;
        else
            toSend = (unsigned short)length;
	} // while

}


void cedClose()
{
    short code;                                                                        

    if (sHand < 0)
    {
        mexPrintf("1401 not opened for use\n");
        return;
    }
                                                    
    if (code=U14Close1401(sHand))           /* close1401+ */
    {
        mexPrintf("Could not close CED 1401 - Code = %d \n",code);                                          
    }
    else
    {
        mexPrintf("CED-1401 Closed - Good bye!\n");
        sHand = -1;
    }
}                                         
    
void cedCloseX(plhs)
mxArray *plhs[];
{
    double *pr;
    short code;                                                                        

    if (sHand < 0)
    {
        mexErrMsgTxt("1401 not opened for use\n");
    }
                                                    
    code=U14Close1401(sHand);           /* close1401+ */
    if (code==U14ERR_NOERROR)
    {
     sHand=-1;
    }
	else
	{
     mexPrintf("Could not close CED 1401 - Code = %d \n",code); 
}
    plhs[0]=mxCreateDoubleMatrix(1,1,mxREAL);  // return code value
    pr = mxGetPr(plhs[0]);
    *pr = (double)code;
}



void cedReset()
{                                                  
    short code;                                                                        

    if (sHand < 0)
    {
        mexPrintf("1401 not opened for use\n");
        return;
    }
                                                    
    if (code=U14Reset1401(sHand))           /* reset1401+ */
    {
        mexPrintf("Could not reset CED-1401+ - Code = %d \n\n",code);                                          
    }
    else
        mexPrintf("CED reset!\n");
}

void cedResetX(plhs)  //returns code if open
mxArray *plhs[];
{                                                  
    short code;
    double *pr;                                                                        

    if (sHand < 0)
    {
        mexPrintf("1401 not opened for use\n");
        code=sHand;
    }
    else
    {
      code=U14Reset1401(sHand);
    }
    plhs[0]=mxCreateDoubleMatrix(1,1,mxREAL);  
    pr = mxGetPr(plhs[0]);
    *pr = (double)code;                                                   
}                                           
           

void cedLd(nrhs,prhs) 
int nrhs;
const mxArray *prhs[];      
{                                           
    long lRetVal;                
    char ldcmd[200];
    char cmd[20];
    int n;
	short sErr;

    if (sHand < 0)
    {
        mexPrintf("1401 not opened for use\n");
        return;
    }

    ldcmd[0] = '\0';
    if(nrhs<2) {
       mexPrintf("No commands specified to load!\n");
       return;
    }

    for(n=1;n<nrhs;n++){
        mxGetString(prhs[n],cmd,1+mxGetN(prhs[n]));  
        strcat(ldcmd,cmd);
        if(n<nrhs-1) strcat(ldcmd,",");
    }
                                                                                      
    lRetVal=U14Ld(sHand, "", ldcmd);  /* attempt to load commands */
    sErr=(short)(lRetVal & 0xFFFF);
	if (sErr != U14ERR_NOERROR)
	{	
    mexPrintf("Could not load command(s), error: %d\n", sErr);                                          
    } 
}  

void cedLdX(nrhs,prhs) 
int nrhs;
const mxArray *prhs[];      
{                                           
    long lRetVal;
	char lddir[255];
    char ldcmd[200];
    char cmd[20];
    int n;
	short sErr;

    if (sHand < 0)
    {
        mexPrintf("1401 not opened for use\n");
        return;
    }

    ldcmd[0] = '\0';
    if(nrhs<3) {
       mexPrintf("Not enough arguments- need directory and command(s)\n");
       return;
    }
    mxGetString(prhs[1],lddir,1+mxGetN(prhs[1]));  // directory first
    for(n=2;n<nrhs;n++){
        mxGetString(prhs[n],cmd,1+mxGetN(prhs[n]));  
        strcat(ldcmd,cmd);
        if(n<nrhs-1) strcat(ldcmd,",");
    }
                                                                                      
    lRetVal=U14Ld(sHand, lddir, ldcmd); //attempt to load commands                 
    sErr=(short)(lRetVal & 0xFFFF);
	if (sErr != U14ERR_NOERROR)
	{  
		mexPrintf("Could not load command(s), error: %d\n", sErr);                                          
    } 
}                                       
    
void cedSendString(nrhs,prhs) 
int nrhs;
const mxArray *prhs[];      
{                                           
    short code;                
    char cmd[1024];

    if (sHand < 0)
    {
        mexPrintf("1401 not opened for use\n");
        return;
    }

    if(nrhs<2) return;
    mxGetString(prhs[1],cmd,1+mxGetN(prhs[1]));  
                                                                            
    if(code=U14SendString(sHand, (LPSTR) cmd))  /* send a string ... */                 
      mexPrintf("Could not send string!, error code: %d\n", code);                                          
}                                         
            
  
void cedGetString(plhs) 
mxArray *plhs[];      
{                                           
    short code;                
    char cmd[250];

    if (sHand < 0)
    {
        mexPrintf("1401 not opened for use\n");
        return;
    }
                                                                            
    if(code=U14GetString(sHand, (LPSTR)cmd, (WORD)250))  /* get a string .. */                 
      mexPrintf("Could not get string!, error code: %d\n",code);                                            

    plhs[0] = mxCreateString(cmd);
}             
     

void cedStateOf1401()
{
    short code;                                                                        

    if (sHand < 0)
    {
        printf("1401 not opened for use\n");
        return;
    }
                                                    
    switch(code=U14StateOf1401(sHand))       /* check state of1401+ */
    {
      case U14ERR_OFF: 
	    printf("The 1401 is turned off...\n");
	    break;
      case U14ERR_NC: 
	    printf("The 1401 is not connected...\n");
	    break;
     case U14ERR_ILL: 
	    printf("The 1401 is unwell (whatever that means..)\n");
	    break;
     case U14ERR_NOIF: 
	    printf("There is no interface card...\n");
	    break;
     case U14ERR_TIME: 
	    printf("The 1401 timed out...\n");
	    break;
     case U14ERR_BADSW: 
	    printf("The 1401 interface card switches are set badly...\n");
	    break;
     case U14ERR_PTIME: 
	    printf("The 1401-plus timed out...\n");
	    break;
     case U14ERR_NOINT: 
	    printf("Could not get interrupt channel wanted...\n");
	    break;
     case U14ERR_INUSE: 
	    printf("The 1401 is in use by another application...\n");
	    break;
     case U14ERR_NODMA: 
	    printf("Could not get DMA channel wanted...\n");
	    break;
     default:
	    printf("CED Status: Ok!\n");
	    break;
    }                     
}                    
  
void cedStat1401(plhs)
mxArray *plhs[];
{                                                  
    double *pr;
    short code;

    if (sHand < 0)
    {
        printf("1401 not opened for use\n");
        return;
    }

    plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);   
    pr = mxGetPr(plhs[0]); 
                                                                                                        
    code=U14Stat1401(sHand);
    *pr = (double) code;
}

void cedGetUserMemorySize(plhs)
mxArray *plhs[]; 
{                                                  
    short code; 
    long memsize; 
    double *pr;  

    if (sHand < 0)
    {
        printf("1401 not opened for use\n");
        return;
    }

    plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);   
    pr = mxGetPr(plhs[0]);                                              
                                                    
    if(code=U14GetUserMemorySize(sHand, (long *) &memsize))                     
      printf("Could not get memory size - Code = %d \n\n",code);

    *pr = (double) memsize;
}                                         
                

void cedGetTimeOut(plhs)
mxArray *plhs[];
{
    long tout;
    double *pr;

    if (sHand < 0)
    {
        printf("1401 not opened for use\n");
        tout=sHand;
    }
    else { 
    tout = U14GetTimeout(sHand);                       
	}
    plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);
    pr = mxGetPr(plhs[0]);
    *pr = (double) tout;
}

void cedSetTimeOut(nrhs,prhs)
int nrhs;
const mxArray *prhs[];
{
    double *pr;

    if (sHand < 0)
    {
        printf("1401 not opened for use\n");
        return;
    }
             
    if(nrhs<2)
    {
        printf("Need to pass timeout as parameter...\n");
        return;
    }      
    pr = mxGetPr(prhs[1]);
    U14SetTimeout(sHand, (long) *pr);    
}

void cedLongsFrom1401(plhs,nrhs,prhs)
int nrhs;
mxArray *plhs[];
const mxArray *prhs[];
{
    double *pr;
	short alLen;
	short sErr;
	short i;
	long *alVal;  //allow a bit extra
    if (sHand < 0)
    {
        printf("1401 not opened for use\n");
        return;
    }
             
    if(nrhs<2)
    {
        mexPrintf("Need to pass no. of longs (us. 2) as a parameter...\n");
        return;
    } 
    pr= mxGetPr(prhs[1]);
	alLen=(short)*pr;
    if (alLen < 1 )
	{ 
       mexPrintf("No. of longs must be > 0\n");
       return;
    }
    alVal=mxCalloc(alLen,sizeof(long));
    sErr=U14LongsFrom1401(sHand, alVal, alLen);
    if (sErr < 1)
    {
	   mexPrintf("U14LongsFrom1401 returns: %d\n",sErr);
	   return;
    }
	plhs[0] = mxCreateDoubleMatrix(1,sErr,mxREAL);   
    pr = mxGetPr(plhs[0]);   
	for (i=0;i<sErr;i++)
	   {
		   *pr++=(double)alVal[i];
	   }
    mxFree(alVal);  //free memory
}
   
void cedTransferFlags(plhs)
// return transfer flags - see use1401.h
mxArray *plhs[];
{
  double *pr;
  short ret;

      if (sHand < 0)
    {
        mexErrMsgTxt("1401 not opened for use\n");
    }
     ret=U14TransferFlags(sHand);
     plhs[0]=mxCreateDoubleMatrix(1,1,mxREAL);
	 pr=mxGetPr(plhs[0]);
	 *pr=(double)ret;
}

void cedSetTransfer(nrhs,prhs)
// uses mxCalloc, so memory is used from Matlab heap
// usage:  matced64c('cedSetTransfer',wArea,dwlength);
int nrhs;
const mxArray *prhs[];
{
	double *pr;
	unsigned short wArea;
    unsigned int dwLength;  //no of bytes
	short sErr;


      if (sHand < 0)
    {
        mexErrMsgTxt("1401 not opened for use\n");
    }
         if(nrhs<3)
    {
        mexErrMsgTxt("Need to pass wArea and dwLength as parameters..\n");
    }   
        pr= mxGetPr(prhs[1]);
	    wArea=(unsigned short)*pr;
		if ((wArea <0) || (wArea >7))
                mexErrMsgTxt("wArea value not appropriate (0-7)");
		pr=mxGetPr(prhs[2]);
		dwLength=(unsigned int)*pr;
		tf_pr[wArea]=mxCalloc(dwLength,sizeof(byte));
		/* register an exit function */
		mexAtExit(FreeTFMemory);
        sErr=U14SetTransArea(sHand,wArea,tf_pr[wArea],dwLength,0); // 
		mexMakeMemoryPersistent(tf_pr[wArea]);
		if (sErr != U14ERR_NOERROR)
		{
			mxFree(tf_pr[wArea]);
			mexPrintf("Error in U14SetTransArea, returns: %d\n",sErr);
			return;
		}
		// it's up to the user to free the memory now via cedUnSetTransfer or cedGetTransdata
}

void cedUnSetTransfer(nrhs,prhs)
// call this to free allocated memory, once data collection is complete
int nrhs;
const mxArray *prhs[];
{
	double *pr;
	unsigned short wArea;
	short sErr;

      if (sHand < 0)
    {
        mexErrMsgTxt("1401 not opened for use\n");
    }
         if(nrhs<2)
    {
        mexErrMsgTxt("Need to pass wArea as parameter..\n");
    }  
        pr= mxGetPr(prhs[1]);
	    wArea=(unsigned short)*pr;
		if ((wArea <0) || (wArea >7))
                mexErrMsgTxt("wArea value not appropriate (0-7)");
		if (tf_pr[wArea] > 0 ) 
		{
        sErr=U14UnSetTransfer(sHand,wArea);
		if (sErr==U14ERR_NOERROR) {
		   mxFree(tf_pr[wArea]);
		   tf_pr[wArea]=0;  // flag cleared
								}
		else {
		   mexPrintf("Error in U14UnSetTransfer, returns: %d\n",sErr);
		   return;
			}
		}  //if pr_tf[wArea]
}

void cedGetTransData(plhs,nrhs,prhs)
// this call returns the data and also frees the memory in Matlab
// call:  array=matced64c('cedGetTransdata',wArea,dataLength,dataType);
int nrhs;
mxArray *plhs[];
const mxArray *prhs[];
{
	double *pr;
	unsigned short wArea;
	unsigned int dataLength;
	short *prShort;
	byte  *prByte;
//	short sErr;
	unsigned int i;
	short dataType;  // use CFS conventions, accept 0,1 (INT1,WRD1) or 2 (INT2)

      if (sHand < 0)
    {
        mexErrMsgTxt("1401 not opened for use\n");
    }
         if(nrhs<4)
    {
        mexErrMsgTxt("Need to pass wArea, dataLength and dataType as parameters.\n");
    }
        pr= mxGetPr(prhs[1]);
	    wArea=(unsigned short)*pr;
		if ((wArea <0) || (wArea >7))
                mexErrMsgTxt("wArea value not appropriate (0-7)");
		pr=mxGetPr(prhs[2]);
		dataLength=(unsigned int)*pr;
		pr=mxGetPr(prhs[3]);
        dataType=(short)*pr;
		if ((dataType < 0) || (dataType > 2))
              mexErrMsgTxt("dataType value not appropriate (0-2)");
	    plhs[0] = mxCreateDoubleMatrix(1,dataLength,mxREAL);   
        pr = mxGetPr(plhs[0]);
		if (dataType==2)
		{
			prShort=tf_pr[wArea]; // force reassignment
	        for (i=0;i<dataLength;i++)  //send it back
			{
		         *pr++=(double)*prShort++;
			}
		} else // do byte transfer - not tested as largely obsolete now
		{
			prByte=tf_pr[wArea];
            for (i=0;i<dataLength;i++)  //send it back
			{
		         *pr++=(double)*prByte++;
			}
		}

		// now unlock the area - removed in v3.1 - must release via cedUnSetTransfer

    /*    sErr=U14UnSetTransfer(sHand,wArea);
		if (sErr!=U14ERR_NOERROR) 
		{
		   mexPrintf("Error in U14UnSetTransfer, returns: %d\n",sErr);
		   return;
		}
	    mxFree(tf_pr[wArea]);  // and free the memory for Matlab
		tf_pr[wArea]=0;  // flag cleared  */
}
  

void cedTypeOf1401(plhs)
mxArray *plhs[]; 
{                                                  
    short type1401; 
    double *pr;  

    if (sHand < 0)
    {
        printf("1401 not opened for use\n");
        return;
    }

    plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);   
    pr = mxGetPr(plhs[0]);                                              
                                                    
    type1401=U14TypeOf1401(sHand);
	if (type1401 <=0) {
      printf("Could not get type of 1401 - error code = %d \n",type1401);
	}

    *pr = (double) type1401;
}  


void cedWorkingSet(plhs,nrhs,prhs)
// this call allows the WorkingSet to be specified,
// needs two input arguments low and high (in KB) eg 400 and 4000
int nrhs;
mxArray *plhs[];
const mxArray *prhs[];
{                                                  
    short res;
    double *pr;
	unsigned long dwMin;
	unsigned long dwMax;

    if (sHand < 0)
    {
        printf("1401 not opened for use\n");
        return;
    }
    if(nrhs<3)
    {
        mexErrMsgTxt("Need to pass dwMin and dwMax.. \n");
    }  
      pr= mxGetPr(prhs[1]);
	  dwMin=(unsigned long)*pr;
	  pr=mxGetPr(prhs[2]);
	  dwMax=(unsigned long)*pr;
	  res=U14WorkingSet(dwMin,dwMax);
	  if (res > 0) {
		  printf("An error has occurred, value: %d\n",res);
	  }
      plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);   
      pr = mxGetPr(plhs[0]);                                                                                             
     *pr = (double) res;
}  



void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])                                                 
//int nlhs;                                                                        
//Matrix *plhs[];                                                                  
//int nrhs;                                                                        
//Matrix *prhs[];

                                                                  
{                                                                                                                                   
    char str[80];


                      
    mxGetString(prhs[0], str, 1+mxGetN(prhs[0]));               
                                                                                                                                         
    if (!strcmp(str,"cedOpen"))
    {
        cedOpen();                                            
        return;        
    }

    if (!strcmp(str,"cedOpenX"))
    {
        if (nlhs !=1) {
                       mexErrMsgTxt("One output argument is required!");
                      }
        cedOpenX(plhs,nrhs,prhs);                                             
        return;        
    }


    if (!strcmp(str,"cedClose"))
    {
        cedClose();                                            
        return;        
    }     


    if (!strcmp(str,"cedCloseX"))
    {
        if (nlhs !=1) {
                       mexErrMsgTxt("One output argument is required!");
                      }
        cedCloseX(plhs);                                            
        return;        
    }


    if (!strcmp(str,"cedReset"))
    {
        cedReset();                                            
        return;        
    }   

    if (!strcmp(str,"cedResetX"))
    {
        if (nlhs !=1) {
                       mexErrMsgTxt("One output argument is required!");
                      }
        cedResetX(plhs);                                            
        return;        
    }  

    if (!strcmp(str,"cedStateOf1401"))
    {
        cedStateOf1401();                                            
        return;        
    }       
      
    if (!strcmp(str,"cedGetUserMemorySize"))
    {
        if (nlhs !=1) {
                       mexErrMsgTxt("One output argument is required!");
                      }
        cedGetUserMemorySize(plhs); 
        return;        
    }       
       
    if (!strcmp(str,"cedStat1401"))
    {
        if (nlhs !=1) {
                       mexErrMsgTxt("One output argument is required!");
                      }
        cedStat1401(plhs);                                            
        return;        
    }  

    if (!strcmp(str,"cedLd"))
    {
        cedLd(nrhs,prhs); 
        return;        
    }   

    if (!strcmp(str,"cedLdX"))
    {
        cedLdX(nrhs,prhs); 
        return;        
    }   


    if (!strcmp(str,"cedSendString"))
    {
        cedSendString(nrhs,prhs); 
        return;        
    }       

    if (!strcmp(str,"cedGetString"))
    {                       
        if (nlhs !=1) {
                       mexErrMsgTxt("One output argument is required!");
                      }               
        cedGetString(plhs); 
        return;        
    }                     
      
    if (!strcmp(str,"cedToHost"))
    {
        if (nlhs !=1) {
                       mexErrMsgTxt("One output argument is required!");
                      }
        cedToHost(plhs,nrhs,prhs); 
        return;        
    }                     
       
    if (!strcmp(str,"cedTo1401"))
    {
        cedTo1401(nrhs,prhs); 
        return;        
    }                  

    if (!strcmp(str,"cedSetTimeOut"))
    {
        cedSetTimeOut(nrhs,prhs); 
        return;        
    }                    

    if (!strcmp(str,"cedGetTimeOut"))
    {
        if (nlhs !=1) {
                       mexErrMsgTxt("One output argument is required!");
                      }
        cedGetTimeOut(plhs); 
        return;        
    }   
	// ver 3 routines:

	    if (!strcmp(str,"cedLongsFrom1401"))
    {
        if (nlhs !=1) {
                       mexErrMsgTxt("One output argument is required!");
                      }
        cedLongsFrom1401(plhs,nrhs,prhs); 
        return;        
    } 

	    if (!strcmp(str,"cedTransferFlags"))
    {
        if (nlhs !=1) {
                       mexErrMsgTxt("One output argument is required!");
                      }
        cedTransferFlags(plhs); 
        return;        
    } 

    if (!strcmp(str,"cedSetTransfer"))
    {
        cedSetTransfer(nrhs,prhs); 
        return;        
    } 

    if (!strcmp(str,"cedUnSetTransfer"))
    {
        cedUnSetTransfer(nrhs,prhs); 
        return;        
    } 

    if (!strcmp(str,"cedGetTransData"))
    {
        if (nlhs !=1) {
                       mexErrMsgTxt("One output argument is required!");
                      }
        cedGetTransData(plhs,nrhs,prhs); 
        return;        
    } 
	
	    if (!strcmp(str,"cedTypeOf1401"))
    {
        if (nlhs !=1) {
                       mexErrMsgTxt("One output argument is required!");
                      }
        cedTypeOf1401(plhs);
        return;        
    }

	    if (!strcmp(str,"cedWorkingSet"))
    {
        if (nlhs !=1) {
                       mexErrMsgTxt("One output argument is required!");
                      }
        cedWorkingSet(plhs,nrhs,prhs);
        return;        
    }


    printf("Error: Unknown CED command: %s!!!\n\n",str);                   
}           
                                                           

