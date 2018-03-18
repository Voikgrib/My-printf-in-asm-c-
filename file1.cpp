//Вызывающая программа file1.cpp

#include<iostream>
#include<stdio.h>

using namespace std;

extern "C" void my_printf(char* , ...);

int main() 
{
	char t = 'S';
	int bin = 16;
	int razr_o = 24;
	int eda = 3802;
	int ten = 42;
	
  	my_printf("Char = <%c> bin in binary = <%b> in 8razr = <%o> eda = <%x> otvet = <%d> string = <%s>  ", t, bin, razr_o, eda, ten, "Oy eeeeee"); 	

  	return 0;
}
