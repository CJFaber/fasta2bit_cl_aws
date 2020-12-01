//__constant char MASK = '\x06';
//__constant int c_len = ((DATA_SIZE-1)/VECTOR_SIZE +1)/LOCAL_MEM_SIZE;
#define FIRST_POS   6
#define SECOND_POS  4
#define THIRD_POS 	2
#define FOURTH_POS  0


__attribute__((vect_type_hint(char16)))
__attribute__((read_req_size(1,1,1)))
__kernel
void FastaTo2Bit_loop(global const char16* inp_dna, global char4* outp_dna, const unsigned int size)
{
	char16 out = '\x00';
	//char16 temp = '\x00';
	char16 MASK = '\x06';
	__attribute__((xcl_pipeline_loop(1)))
	//printf("--INSIDE KERNEL--\nNum of size: %u\n", size);
	for(unsigned int i = 0; i < size;  i++)
	{	
		/*
		printf("---------Testing Input------------\n");	
		printf("%#08x\n", inp_dna[i].s0);
		printf("%#08x\n", inp_dna[i].s1);
		printf("%#08x\n", inp_dna[i].s2);
		printf("%#08x\n", inp_dna[i].s3);
		printf("%#08x\n", inp_dna[i].s4);
		printf("%#08x\n", inp_dna[i].s5);
		printf("%#08x\n", inp_dna[i].s6);
		printf("%#08x\n", inp_dna[i].s7);
		printf("%#08x\n", inp_dna[i].s8);
		printf("%#08x\n", inp_dna[i].s9);
		printf("%#08x\n", inp_dna[i].sa);
		printf("%#08x\n", inp_dna[i].sb);
		printf("%#08x\n", inp_dna[i].sc);
		printf("%#08x\n", inp_dna[i].sd);
		printf("%#08x\n", inp_dna[i].se);
		printf("%#08x\n", inp_dna[i].sf);
		//temp = '\x00';
		*/
		out = '\x00';
        
		//__attribute__((xcl_pipeline_loop(1)))
        //__attribute__((xcl_loop_tripcount(4, 4)))
        //for (int j = 0 ; j < 4; j++){
        out = inp_dna[i] & MASK;
		out = out >> 1;
			//temp = temp << (6 - 2*j);
			//out = out|temp;
			//printf("%#08x\n", out); 
		//}
		//printf("%#08x\n", out); 
		outp_dna[i].s0 = out.s0 << FIRST_POS | out.s1 << SECOND_POS | out.s2 << THIRD_POS | out.s3 << FOURTH_POS;
		//printf("0x%02X\n", (unsigned char)outp_dna[i].s0);
		outp_dna[i].s1 = out.s4 << FIRST_POS | out.s5 << SECOND_POS | out.s6 << THIRD_POS | out.s7 << FOURTH_POS;
		//printf("0x%02X\n", (unsigned char)outp_dna[i].s1);
		outp_dna[i].s2 = out.s8 << FIRST_POS | out.s9 << SECOND_POS | out.sA << THIRD_POS | out.sB << FOURTH_POS;
		//printf("0x%02X\n", (unsigned char)outp_dna[i].s2);
		outp_dna[i].s3 = out.sC << FIRST_POS | out.sD << SECOND_POS | out.sE << THIRD_POS | out.sF << FOURTH_POS;
    	//printf("0x%02X\n", (unsigned char)outp_dna[i].s3);
	}
}
