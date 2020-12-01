#define INPUT_LINE  512
#define OUTPUT_LINE 128

#define ASCIItoBinMask '\x06'	// Byte char value
#define PackSize 64				// How many bases per Input Line

#include "ap_axi_sdata.h"
#include "ap_int.h"
#include "hls_stream.h"

typedef qdma_axis<INPUT_LINE,0,0,0> ASCII_Line;	//datap;
typedef qdma_axis<OUTPUT_LINE,0,0,0> TwoBit_Line;

//Streaming Kernel version
extern "C" {
void FastaTo2Bit_Stream(                                                 
   	hls::stream<ASCII_Line> &input,                                                  
  	hls::stream<TwoBit_Line> &output)                                           
{                                                                      
   	#pragma HLS INTERFACE axis port=input
	#pragma HLS INTERFACE axis port=output
	
   	ASCII_Line input_stream;
	TwoBit_Line output_stream;
   	
	ap_uint<OUTPUT_LINE> temp;
	unsigned int i = 0;
	bool EndOfStream = 0;
	
	ap_uint<INPUT_LINE> curLine;
	ap_uint<OUTPUT_LINE> outLine;
	
	while(true){
		input_stream = input.read();
		curLine << input_stream.get_data();
		if(input_stream.get_last()){
			break;
		}
		
		LineTransform: for (i=0; i < PackSize; i++){
			#pragma HLS pipeline
			#pragma HLS loop_tripcount min=64 max=64
			temp = 0;
			temp = ((char)(curLine >> 8*i)) & ASCIItoBinMask;  	// Pull char value from curLine
			temp = temp >> 1;									// shift 2-bit to front 
			temp = temp << (6 - 2*i);							// shift 2-bit to proper position (one of 64 possible)
			outLine = outLine|temp;								// write 2-bit to output line
		}
		output_stream.set_data(outLine);
		output_stream.set_keep(-1);
		output.write(output_stream);
	}                                                                   
}
}                                                                      
