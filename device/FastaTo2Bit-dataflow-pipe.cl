//__constant char MASK = '\x06';
//__constant int c_len = ((DATA_SIZE-1)/VECTOR_SIZE +1)/LOCAL_MEM_SIZE;

//Little endian
//----------------- Input interger ----------------------
// one input int corresponds to 4 output chars
// 		0x 04  03  02  01

//unsigned int16 corresponds to 64 output chars or 
//

#define BUFFER_SIZE 32768


#define FIRST_POS   6
#define SECOND_POS  4
#define THIRD_POS 	14
#define FOURTH_POS  24
#define INT_MASK_1 0x00000003
#define INT_MASK_2 0x00000300
#define INT_MASK_3 0x00030000
#define INT_MASK_4 0x03000000

pipe uint16 	InputPipe 	__attribute__((xcl_reqd_pipe_depth(128)));
pipe uchar16 	OutputPipe 	__attribute__((xcl_reqd_pipe_depth(128)));

__constant unsigned int c_size_min = 32768;		//512 KiB
__constant unsigned int c_size_max = 16777216;	//256 MiB

//__attribute__((vect_type_hint(char16)))

kernel __attribute__ ((reqd_work_group_size(1, 1, 1)))
void read_inp(__global const uint16 *restrict inp, const unsigned int size)
{	
    __attribute__((xcl_pipeline_loop(1)))
    __attribute__((xcl_loop_tripcount(c_size_min, c_size_max)))
	read: for (unsigned int i = 0; i < size; i++){
		write_pipe_block(InputPipe, &inp[i]);
	}
}


kernel __attribute__ ((reqd_work_group_size(1, 1, 1)))
void write_out(__global uchar16 *restrict out, const unsigned int size)
{
	__attribute__((xcl_pipeline_loop(1)))
    __attribute__((xcl_loop_tripcount(c_size_min, c_size_max)))
    write: for (unsigned int i = 0 ; i < size ; i++){
        read_pipe_block(OutputPipe, &out[i]);
    }
}


kernel __attribute__ ((reqd_work_group_size(1, 1, 1)))
void convert_fasta(const unsigned int size)
{

	__attribute__((xcl_pipeline_loop(1)))
    __attribute__((xcl_loop_tripcount(c_size_min, c_size_max)))
    convert: for (unsigned int i = 0 ; i < size ; i++){
		uint16 hold;
		uchar16 out;
		uint16 MASK = 0x06060606;  //Grab the 2nd and 3rd bit

		read_pipe_block(InputPipe, &hold);

		hold = hold & MASK; //Isolate important bits
		hold = hold >> 1;	//Shift out lsb, will be 0
    	
		// out.sX = 0x( FIRST_POS | SECOND_POS | THIRD_POS | FORTH_POS )
		
		out.s0 = ((hold.s0 & INT_MASK_1) << FIRST_POS) | ((hold.s0 & INT_MASK_2) >> SECOND_POS) |
				  ((hold.s0 & INT_MASK_3) >> THIRD_POS) | ((hold.s0 & INT_MASK_4) >> FOURTH_POS) ;

		out.s1 = ((hold.s1 & INT_MASK_1) << FIRST_POS) | ((hold.s1 & INT_MASK_2) >> SECOND_POS) |
				  ((hold.s1 & INT_MASK_3) >> THIRD_POS) | ((hold.s1 & INT_MASK_4) >> FOURTH_POS) ;

		out.s2 = ((hold.s2 & INT_MASK_1) << FIRST_POS) | ((hold.s2 & INT_MASK_2) >> SECOND_POS) |
				  ((hold.s2 & INT_MASK_3) >> THIRD_POS) | ((hold.s2 & INT_MASK_4) >> FOURTH_POS) ;
		
		out.s3 = ((hold.s3 & INT_MASK_1) << FIRST_POS) | ((hold.s3 & INT_MASK_2) >> SECOND_POS) |
				  ((hold.s3 & INT_MASK_3) >> THIRD_POS) | ((hold.s3 & INT_MASK_4) >> FOURTH_POS) ;

		out.s4 = ((hold.s4 & INT_MASK_1) << FIRST_POS) | ((hold.s4 & INT_MASK_2) >> SECOND_POS) |
				  ((hold.s4 & INT_MASK_3) >> THIRD_POS) | ((hold.s4 & INT_MASK_4) >> FOURTH_POS) ;

		out.s5 = ((hold.s5 & INT_MASK_1) << FIRST_POS) | ((hold.s5 & INT_MASK_2) >> SECOND_POS) |
				  ((hold.s5 & INT_MASK_3) >> THIRD_POS) | ((hold.s5 & INT_MASK_4) >> FOURTH_POS) ;

		out.s6 = ((hold.s6 & INT_MASK_1) << FIRST_POS) | ((hold.s6 & INT_MASK_2) >> SECOND_POS) |
				  ((hold.s6 & INT_MASK_3) >> THIRD_POS) | ((hold.s6 & INT_MASK_4) >> FOURTH_POS) ;

		out.s7 = ((hold.s7 & INT_MASK_1) << FIRST_POS) | ((hold.s7 & INT_MASK_2) >> SECOND_POS) |
				  ((hold.s7 & INT_MASK_3) >> THIRD_POS) | ((hold.s7 & INT_MASK_4) >> FOURTH_POS) ;

		out.s8 = ((hold.s8 & INT_MASK_1) << FIRST_POS) | ((hold.s8 & INT_MASK_2) >> SECOND_POS) |
				  ((hold.s8 & INT_MASK_3) >> THIRD_POS) | ((hold.s8 & INT_MASK_4) >> FOURTH_POS) ;

		out.s9 = ((hold.s9 & INT_MASK_1) << FIRST_POS) | ((hold.s9 & INT_MASK_2) >> SECOND_POS) |
				  ((hold.s9 & INT_MASK_3) >> THIRD_POS) | ((hold.s9 & INT_MASK_4) >> FOURTH_POS) ;

		out.sa = ((hold.sa & INT_MASK_1) << FIRST_POS) | ((hold.sa & INT_MASK_2) >> SECOND_POS) |
				  ((hold.sa & INT_MASK_3) >> THIRD_POS) | ((hold.sa & INT_MASK_4) >> FOURTH_POS) ;

		out.sb = ((hold.sb & INT_MASK_1) << FIRST_POS) | ((hold.sb & INT_MASK_2) >> SECOND_POS) |
				  ((hold.sb & INT_MASK_3) >> THIRD_POS) | ((hold.sb & INT_MASK_4) >> FOURTH_POS) ;

		out.sc = ((hold.sc & INT_MASK_1) << FIRST_POS) | ((hold.sc & INT_MASK_2) >> SECOND_POS) |
				  ((hold.sc & INT_MASK_3) >> THIRD_POS) | ((hold.sc & INT_MASK_4) >> FOURTH_POS) ;

		out.sd = ((hold.sd & INT_MASK_1) << FIRST_POS) | ((hold.sd & INT_MASK_2) >> SECOND_POS) |
				  ((hold.sd & INT_MASK_3) >> THIRD_POS) | ((hold.sd & INT_MASK_4) >> FOURTH_POS) ;

		out.se = ((hold.se & INT_MASK_1) << FIRST_POS) | ((hold.se & INT_MASK_2) >> SECOND_POS) |
				  ((hold.se & INT_MASK_3) >> THIRD_POS) | ((hold.se & INT_MASK_4) >> FOURTH_POS) ;

		out.sf = ((hold.sf & INT_MASK_1) << FIRST_POS) | ((hold.sf & INT_MASK_2) >> SECOND_POS) |
				  ((hold.sf & INT_MASK_3) >> THIRD_POS) | ((hold.sf & INT_MASK_4) >> FOURTH_POS) ;

		write_pipe_block(OutputPipe, &out);

		
	}
}

