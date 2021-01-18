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

__constant uint c_size = 32768;

//__attribute__((vect_type_hint(char16)))


static void read_inp(__global const uint16* inp, uint16* buf_in, const unsigned int size)
{	
    __attribute__((xcl_pipeline_loop(1)))
    __attribute__((xcl_loop_tripcount(c_size, c_size)))
	read: for (unsigned int i = 0; i < size; i++){
		buf_in[i] = inp[i];
	}
}

static void write_out(__global uchar16* out, uchar16* buf_out, const unsigned int size)
{
	__attribute__((xcl_pipeline_loop(1)))
    __attribute__((xcl_loop_tripcount(c_size, c_size)))
    write: for (unsigned int i = 0 ; i < size ; i++){
        out[i] = buf_out[i];
    }
}

void convert_fasta(uint16* inp_buf, uchar16* outp_buf, const unsigned int size)
{

	__attribute__((xcl_pipeline_loop(1)))
    __attribute__((xcl_loop_tripcount(c_size, c_size)))
    convert: for (unsigned int i = 0 ; i < size ; i++){
		uint16 hold = 0;
		uchar16 out = 0;
		uint16 MASK = 0x06060606;

		hold = inp_buf[i] & MASK;
		hold = hold >> 1;
    	
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

		outp_buf[i] = out;
	}
}

__attribute__((xcl_dataflow))
void run_convert(__global const uint16* inp_dna, __global uchar16* outp_dna, const unsigned int size)
{

	uint16 buf_in[BUFFER_SIZE];
	uchar16 buf_out[BUFFER_SIZE];

	read_inp(inp_dna, buf_in, size);
	convert_fasta(buf_in, buf_out, size);
	write_out(outp_dna, buf_out, size);
}

__kernel
__attribute__((reqd_work_group_size(1,1,1)))
void FastaTo2Bit_dataflow(__global const uint16* inp_dna, __global uchar16* outp_dna, const unsigned int size)
{
	run_convert(inp_dna, outp_dna, size);		
}

