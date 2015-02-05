//=======1=========2=========3=========4=========5=========6=========7=========8=========9=========0=========1=========2=========3=========4=========5=========6=========7**
//Author information
//  Author name: Andre White
//  Author email: awhiteis21@fullerton.edu 
//  Author location: Fullerton, Calif.
//Course information
//  Course number: CPSC240
//  Assignment number: 2
//  Due date: 2014-Sep-10
//Project information
//  Project title: Electric Circuits in Parallel
//  Purpose: Use vector processing to compute the correct circuit values
//  Status: In continuous maintenance
//  Project files: hw.asm current.c
//  Modules (subprograms): none
//Module information
//  File name: current.c
//  
//  Language: C
//  Date last modified: 2014-Sept-10
//  Purpose: This module is the top level driver: it will call current()
//  File name: current.c
//  Status: In production.  No known errors.
//  Future enhancements: None planned
//Translator information (Tested in Linux shell)
//  Gnu compiler: 
//  Gnu linker:   gcc -o hw hw.o current.c
//  Execute:      ./hw
//References and credits
//  No references: this module is standard C language
//Format information
//  Page width: 172 columns
//  Begin comments: 61
//  Optimal print specification: Landscape, 7 points or smaller, monospace, 8½x11 paper
#include <stdio.h>

extern double current();
int main(){

	char* welcome= "Welcome to Electric Circuit Processing by Andre White";
	char* exit= "The driver recieved: ";

	double ret=-99.99;
	printf("%s\n",welcome);
	
	ret=current();
	printf("%s %1.18lf\n",exit,ret);
	return 0;
}
