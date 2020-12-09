//__constant char MASK = '\x06';
//__constant int c_len = ((DATA_SIZE-1)/VECTOR_SIZE +1)/LOCAL_MEM_SIZE;

//Little endian
//----------------- Input interger ----------------------
// one input int corresponds to 4 output chars
// 		0x 04  03  02  01

//unsigned int16 corresponds to 64 output chars or 
//


#define FIRST_POS   6
#define SECOND_POS  4
#define THIRD_POS 	14
#define FOURTH_POS  28
#define INT_MASK_1 0x00000003
#define INT_MASK_2 0x00000300
#define INT_MASK_3 0x00030000
#define INT_MASK_4 0x03000000


//__attribute__((vect_type_hint(char16)))
__kernel
__attribute__((xcl_dataflow))
__attribute__((reqd_work_group_size(1,1,1)))
void FastaTo2Bit_loop(global const uint16* inp_dna, global uchar16* outp_dna, const unsigned int size)
{
	//__attribute__((xcl_dataflow))
	__attribute__((xcl_pipeline_loop(1)))
	__attribute__((opencl_unroll_hint))
	LOOP_1: for(unsigned int i = 0; i < size;  i++)
	{
		
		uint16 hold = 0;
		uchar16 out = 0;
		uint16 MASK = 0x06060606;
		/*	
		if(i == 0){	
			printf("---------Testing Input------------\n");	
			printf("%u\n", inp_dna[i].s0);
			printf("%u\n", inp_dna[i].s1);
			printf("%u\n", inp_dna[i].s2);
			printf("%u\n", inp_dna[i].s3);
			printf("%u\n", inp_dna[i].s4);
			printf("%u\n", inp_dna[i].s5);
			printf("%u\n", inp_dna[i].s6);
			printf("%u\n", inp_dna[i].s7);
			printf("%u\n", inp_dna[i].s8);
			printf("%u\n", inp_dna[i].s9);
			printf("%u\n", inp_dna[i].sa);
			printf("%u\n", inp_dna[i].sb);
			printf("%u\n", inp_dna[i].sc);
			printf("%u\n", inp_dna[i].sd);
			printf("%u\n", inp_dna[i].se);
			printf("%u\n", inp_dna[i].sf);
		}
		*/
		//__attribute__((xcl_pipeline_loop(1)))
        //__attribute__((xcl_loop_tripcount(4, 4)))
        //for (int j = 0 ; j < 4; j++){
        //if(i == 0){
		//	printf("%X\n", inp_dna[i].s0);
		//}
		hold = inp_dna[i] & MASK;
		//if(i == 0){
		//	printf("%X\n", hold.s0);
		//}
		hold = hold >> 1;
		//if(i == 0){
		//	printf("%X\n", hold.s0);	
		//}
			//temp = temp << (6 - 2*j);
			//hold = hold|temp;
			//printf("%#08x\n", hold); 
		//}
		//out.s0 = hold.s0 << FIRST_POS | hold.s1 << SECOND_POS | hold.s2 << THIRD_POS | hold.s3 << FOURTH_POS;
		//printf("0x%02X\n", (unsigned char)out[i].s0);
		//out.s1 = hold.s4 << FIRST_POS | hold.s5 << SECOND_POS | hold.s6 << THIRD_POS | hold.s7 << FOURTH_POS;
		//printf("0x%02X\n", (unsigned char)out[i].s1);
		//out.s2 = hold.s8 << FIRST_POS | hold.s9 << SECOND_POS | hold.sA << THIRD_POS | hold.sB << FOURTH_POS;
		//printf("0x%02X\n", (unsigned char)out[i].s2);
		//out.s3 = hold.sC << FIRST_POS | hold.sD << SECOND_POS | hold.sE << THIRD_POS | hold.sF << FOURTH_POS;
    	//printf("0x%02X\n", (unsigned char)out[i].s3);
    	//outp_dna[i] = out;
    	
		// out.sX = 0x( FIRST_POS | SECOND_POS | THIRD_POS | FORTH_POS )

		out.s0 = ((hold.s0 & INT_MASK_1) << FIRST_POS) | ((hold.s0 & INT_MASK_2) >> SECOND_POS) |
				  ((hold.s0 & INT_MASK_3) >> THIRD_POS) | ((hold.s0 & INT_MASK_4) >> FOURTH_POS) ;
		//if(i == 0){
		//	printf("%#08x\n", out.s0); 
		//}
		
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

		outp_dna[i] = out;
	}

}

	

