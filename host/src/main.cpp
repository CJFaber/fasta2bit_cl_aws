#define INP_STREAM_WIDTH	64		//Number of Chars in width of input stream (512 bits / 8 bits in a char)
#define OUT_STREAM_WIDTH	16		//Number of Chars in width of output stream (64 values * 2bits per value) / 8 bits in a char 

//For use with Dataflow:
#define FILE_SPLIT			524288		//Split files on 512KiB (Dataflow kernel has 32KiB internal buffers)

//For use with loop:
//#define FILE_SPLIT		1084576		//Split files on 4MiB (4MiB / 4 for number of ints)


//Vitis CL includes
#include "xcl2.hpp"
#include <CL/cl_ext_xilinx.h>

//C++ includes
#include <vector>
#include <fstream>
#include <limits>
#include <deque>
#include <omp.h>

//User includes
#include "../inc/fastato2bit.h"
#include "../inc/CrunchServer.hpp"



//FastaTo2Bit_loop
//const std::string kernel_name = "FastaTo2Bit_loop";
//FastaTo2Bit_dataflow
const std::string kernel_name = "FastaTo2Bit_dataflow";

using std::vector;
using std::deque;

int main(int argc, char* argv[]) {

	if (argc !=3){
		std::cout << "Usage: " << argv[0] << " <InputFile.fasta>" << " <XCLBIN File>" << std::endl;
		return EXIT_FAILURE;
  	}	
  
	//double atime1 = omp_get_wtime();

  	////////////////////////////////////////////////////////
  	//Open DataFile and create buffers	
	std::string binaryFile = argv[2];
	/*
	std::ifstream f;
	f.open(argv[1], std::ios_base::in | std::ios_base::binary);

	deque<vector<char, aligned_allocator<char>>> InpQueue;	//Char input read from file
	deque<vector<char, aligned_allocator<char>>> OutQueue;	//2-Bit packed out
	//deque<vector<char, aligned_allocator<char>>> InpQueue;
	//deque<vector<char>>> OutQueue;
	f.ignore ( std::numeric_limits<std::streamsize>::max() ); //Run to end of file
	size_t inp_size = (size_t)f.gcount();
	f.clear(); 											  //Reset
	f.seekg(0,std::ios_base::beg);						  //Return to beginning

	
	//Split input file on 32MB Lines.
	//	and pad if need be
	inp_size = 0;
	while(!f.eof()){
		InpQueue.emplace_back(FILE_SPLIT, 0);
		//std::vector<char> Hold(FILE_SPLIT, 0); 
		f.read(InpQueue.back().data(), InpQueue.back().size());
		//f.read(Hold.data(), Hold.size());
		size_t NumRead = (size_t)f.gcount();
		if(NumRead == 0){
			InpQueue.pop_back();
			continue;
		}
		#ifdef DEBUG
			std::cout << "\nNumRead is: " << NumRead <<std::endl;
			std::cout << "Vector size is: " << InpQueue.back().size() << std::endl;
		#endif
		//Verify that we either read the size of file split or pad to make even.
		//This should only fire once per file
		if(NumRead != FILE_SPLIT){
			InpQueue.back().resize(NumRead);
			InpQueue.back().shrink_to_fit();
			//Hold.resize(NumRead);
			std::cout << "We are not at FILE_SPLIT NumRead is:" << NumRead << std::endl;
			//Find out if the vector needs to be resized to be divisible by 16 for vector instruction
			if( (NumRead % 16) != 0 ){
				std::cout << "got in trap\n";
				NumRead += (16 - (NumRead % 16));
				std::cout << "NumRead is now: " << NumRead << std::endl;
			}
			//This is dumb but for some reason resize doesn't work with the aligned alocator
			InpQueue.back().resize(NumRead, 'A');
			//InpQueue.back().shrink_to_fit();
			//Hold.resize(NumRead, 'A');
			//std::cout << "Size of vector is now: " << InpQueue.back().size() << std::endl;	
		}
		
		std::cout << "Size of input queue is now: " << InpQueue.size() << std::endl;	
		inp_size += NumRead;
		OutQueue.emplace_back(NumRead/4, 0);
		#ifdef DEBUG_rm
        	for (auto i = InpQueue.back().begin(); i != InpQueue.back().end(); ++i){
				std::cout << +(*i);
            }
			std::cout << "\nNumRead is: " << NumRead <<std::endl;
		#endif
	}
	*/

		
	FILE* f = fopen(argv[1], "r");

	if (f==NULL) {
		std::cout << "File error\n"; 
		exit (1);
	}
	//Find size of file
	fseek (f, 0 , SEEK_END);
  	size_t inp_size = ftello(f); //Number of bases in the file
  	rewind(f);

	deque<vector<unsigned int, aligned_allocator<unsigned int>>> InpQueue;	//Char input read from file
	deque<vector<char, aligned_allocator<char>>> OutQueue;					//2-Bit packed out - Each char is 4 bases
	
	std::cout << "Gcount returned (total num of DNA bases): "<<inp_size << std::endl;
	size_t num_int = inp_size / sizeof(unsigned int) + (inp_size % sizeof(unsigned int) != 0);	
	size_t outp_size = inp_size / 4 + (inp_size % 4 != 0);
	std::cout << "Total number of integers: "<< num_int << std::endl;
	std::cout << "Total Number of 2bit compacted chars: " << outp_size << std::endl <<std::endl;

	//InpQueue.emplace_back(FILE_SPLIT, 0);
	size_t num_read = 0;			//Number of integers read 
	std::vector<unsigned int, aligned_allocator<unsigned int>> Hold;
		
	while(num_read < num_int)
	{
		size_t num_to_read = FILE_SPLIT;
		if( (num_read + FILE_SPLIT) > num_int ){
			//adjust size for smaller file input should only happen once
			num_to_read = num_int - num_read;
		}
		Hold.resize(num_to_read, 0);
		#ifdef DEBUG
			std::cout << "num_to_read is: " << num_to_read << std::endl;
		#endif
		if( (fread(Hold.data(), (sizeof(unsigned int)), num_to_read, f) % 16 )){
			std::cout << "Fell into not devisiable by 16 trap. Hold is: " << Hold.size() <<std::endl;
			int pad_num = 16 - (Hold.size() % 16);
			Hold.insert(Hold.end(), pad_num, 1094795585); //'AAAA'
			std::cout << "New vector length is: " << Hold.size() <<std::endl;
		}
		InpQueue.emplace_back(Hold);
		#ifdef DEBUG
			std::cout << "Read into queue: " << num_to_read << " :: " << InpQueue.back().size();
			std::cout << " :: " << Hold.size() << std::endl;
			#ifdef PRINTOUT	
			for (auto i = InpQueue.back().begin(); i != InpQueue.back().end(); ++i){
               	std::cout << +(*i) << std::endl;
           	}
			#endif
			std::cout << std::endl;	
		#endif
		//OutQueue.emplace_back(num_to_read, 0);
		// Should be identical to the number of integers read in, some number divisable by 16	
		OutQueue.emplace_back(Hold.size(), 0);
		#ifdef DEBUG
			std::cout << "OutQueue vector added of size: " << OutQueue.back().size() << std::endl;
			std::cout << "InpQueue vector added of size: " << InpQueue.back().size() << std::endl;
		#endif
		num_read += num_to_read;
	}
	
	#ifdef DEBUG
		std::cout << "OutQueue size: " << OutQueue.size() << std::endl;
		std::cout << "InpQueue size: " << InpQueue.size() << std::endl;
	#endif
	

	//Create the DataCrunch Server.	
	CrunchServer serv;
		
	cl_int err;
	cl::CommandQueue clQueue;
	cl::Kernel fasta_transform_kernel;
	cl::Context context;
	

	/////////////////////////
	//Aligned Data
	//
	//cl_mem_ext_ptr_t ext;
    
	//debug
	std::cout << "DNA input bases: "<< inp_size << std::endl;
	std::cout << "DNA output Bases: "<< outp_size << std::endl;
	//copy in data
	
	//Copy input data into vector. 	

	//std::vector<char, aligned_allocator<char>> TwoBit_out(outp_size, 0);

	//double ctime1 = omp_get_wtime();
	

	/////////////////////////////////////////////////////////////////////////////
	//Create OpenCL program componets
	//Init platforms and devices
	std::vector<cl::Device> devices = xcl::get_xil_devices();
	auto afiBuf = xcl::read_binary_file(binaryFile);
	cl::Program::Binaries bins{{afiBuf.data(), afiBuf.size()}};

	cl::Device device = devices[0];

	OCL_CHECK(err, context = cl::Context({device}, NULL, NULL, NULL, &err));
	OCL_CHECK(err, clQueue = cl::CommandQueue(context, {device}, CL_QUEUE_PROFILING_ENABLE, &err));

	std::cout << "Programming device: " << device.getInfo<CL_DEVICE_NAME>() << std::endl;
	cl::Program program(context, {device}, bins, NULL, &err);
	 
	if (err != CL_SUCCESS) {
		std::cout << "Failed to program device with xclbin file!\n";
	    std::cout << "Failed to program device, exiting\n";
        exit(EXIT_FAILURE);	
	}
	else {
		std::cout << "Device programmed successfully\n";
		//OCL_CHECK(err, fasta_transform_kernel = cl::Kernel(program, "FastaTo2Bit_dataflow", &err));
		OCL_CHECK(err, fasta_transform_kernel = cl::Kernel(program, (const char*)kernel_name.c_str(), &err));
		//valid_device = true;
	}

	//Start the DataCrunch Server
	serv.Run();
	cl::Event in_mem_transfer_event, out_mem_transfer_event, kernel_event, read_mem_transfer_event;
	
	#ifdef TIMING
		cl_ulong time_start = 0;
    	cl_ulong time_end = 0;
		double time_host_start = 0;
		double time_host_end = 0;
		#ifdef ACC_TIME
			cl_double t_in_mem = 0;
			cl_double t_out_mem = 0;
			cl_double t_kernel = 0;
			cl_double t_read_mem = 0;
			double	 t_host	= 0;
		#endif
	#endif


	std::cout <<"Enter any key to start main loop\n";
	std::cin.get();
	
	//Call time stamp
	TimeStamp();	
	
	while(!InpQueue.empty())
	{
		#ifdef TIMING
			time_host_start = omp_get_wtime();
		#endif
		#ifdef DEBUG
			//std::cout << "Doublecheck on front queue\n";
			//	for (auto i = InpQueue.front().begin(); i != InpQueue.front().end(); ++i){
            //    	std::cout << *i;
            //    }
			std::cout << "Press enter to run loop\n";
			std::cin.get();
		#endif

  	/////////////////////////////////////////////////////////////////////////////
  	//Initalize buffers and build program
  	
	//Input Buffer	
    //svm_inp_dna = (unsigned char*)clSVMAllocAltera(context, CL_MEM_READ_ONLY, (inp_dna.size() * sizeof(unsigned char)), 0);
    	#ifdef DEBUG
			std::cout<<"Creating Buffers\n";
		#endif
		
 		OCL_CHECK(err,
				  cl::Buffer cl_inp(context,
									 //Try timing with copy host ptr
									 CL_MEM_USE_HOST_PTR | CL_MEM_READ_ONLY,
									 //CL_MEM_COPY_HOST_PTR | CL_MEM_READ_ONLY,
									 sizeof(unsigned int)*InpQueue.front().size(),
									 InpQueue.front().data(),
									 &err));	
		#ifdef EXP_ENQUEUE
			OCL_CHECK(err, err = clQueue.enqueueWriteBuffer(
							cl_inp,
							CL_TRUE,
							0,
							sizeof(unsigned int)*InpQueue.front().size(),
							InpQueue.front().data(),
							nullptr,
							&in_mem_transfer_event));

			OCL_CHECK(err, err = fasta_transform_kernel.setArg(0, cl_inp));	
		#endif

						 
    	//Output Buffer
    	//svm_outp_dna = (unsigned char*)clSVMAllocAltera(context, CL_MEM_WRITE_ONLY, (outp_dna.size() * sizeof(unsigned char)), 0);
		OCL_CHECK(err,
			  	cl::Buffer cl_out(context,
									//Try timing with copy host ptr
								  	CL_MEM_USE_HOST_PTR | CL_MEM_WRITE_ONLY,
								  	//CL_MEM_COPY_HOST_PTR | CL_MEM_WRITE_ONLY,
								  	sizeof(char)*OutQueue.front().size(),
								  	OutQueue.front().data(),
								  	&err));

		#ifdef EXP_ENQUEUE
			OCL_CHECK(err, err = clQueue.enqueueWriteBuffer(
							cl_out,
							CL_TRUE,
							0,
							sizeof(char)*OutQueue.front().size(),
							OutQueue.front().data(),
							nullptr,
							&out_mem_transfer_event));

    		OCL_CHECK(err, err = fasta_transform_kernel.setArg(1, cl_out));
		#endif
    	
		//Set OpenCL kernel inputs
		#ifndef EXP_ENQUEUE
			OCL_CHECK(err, err = fasta_transform_kernel.setArg(0, cl_inp));	
    		OCL_CHECK(err, err = fasta_transform_kernel.setArg(1, cl_out));	
		#endif
		//Size of number of dna bases to transform, /16 for vector operations. 
		OCL_CHECK(err, err = fasta_transform_kernel.setArg(2, (unsigned int)(InpQueue.front().size()/16)));

		#ifndef EXP_ENQUEUE
			OCL_CHECK(err, err = clQueue.enqueueMigrateMemObjects({cl_inp}, 0, NULL, &in_mem_transfer_event));
		#endif


  		//////////////////////////////////////////////////////////////////
  		// END SETUP - START OCL KERNEL
  		// TODO: add in mwi and swi global memory versions
  		//////////////////////////////////////////////////////////////////
	
		#ifdef DEBUG
			std::cout << "Starting Kernel as task\n";
		#endif

		OCL_CHECK(err, err = clQueue.enqueueTask(fasta_transform_kernel, nullptr, &kernel_event));
		
		#ifdef DEBUG
			std::cout << "Reading back Buffer from FPGA\n";
		#endif

		#ifndef EXP_ENQUEUE
			OCL_CHECK(err, err = clQueue.enqueueMigrateMemObjects({cl_out}, CL_MIGRATE_MEM_OBJECT_HOST, NULL, &read_mem_transfer_event));
		#else
					
			OCL_CHECK(err, err = clQueue.enqueueReadBuffer(
							cl_out,
							CL_TRUE,
							0,
							sizeof(char)*OutQueue.front().size(),
							OutQueue.front().data(),
							nullptr,
							&read_mem_transfer_event));
		#endif

		//#ifdef TIMING
		//	time_host_end += omp_get_wtime() - time_host_start;
		//#endif
		clQueue.finish();

		#ifdef DEBUG
			std::cout << "Sending to server...\n";
			//std::cout << "\t OutQueue vector size is: " << OutQueue.size();
		#endif
		//#ifdef TIMING
		//	time_host_start = omp_get_wtime();
		//#endif
		//Transfer Buffer to CrunchServer
		unsigned int i = 0;
		vector<char, aligned_allocator<char>> &RefHold = OutQueue.front();
		
		vector<char, aligned_allocator<char>>::iterator left_iter = RefHold.begin();
		vector<char, aligned_allocator<char>>::iterator right_iter =  RefHold.begin() + DC_MESSAGE_SIZE;
		
		vector<char> message(DC_MESSAGE_SIZE, 0);
		while( i < OutQueue.front().size() ){
			if((OutQueue.front().size() - i) < DC_MESSAGE_SIZE){
				message.assign(left_iter, OutQueue.front().end());
				message.resize(DC_MESSAGE_SIZE, 0);
			}
			else{
				message.assign(left_iter, right_iter);
				left_iter = right_iter;
				right_iter = right_iter + DC_MESSAGE_SIZE;
			}

			#ifdef DEBUG	
				
  				std::cout << "Output Bector: \n" << "Message Size: "<< message.size() << std::endl;
				#ifdef PRINTOUT
				for (auto i = message.begin(); i != message.end(); ++i){
                	if (*i != 0){
						std::cout << std::hex << (0xFF & (*i)) << " ";
						//std::cout << +(*i) << " ";
            		}
				}		
				std::cout << "\n" << std::dec;
				#endif
			#endif
			#ifndef DISABLE_SERV 
				serv.LoadData(message);
			#endif
			i += message.size();
		
			//std::cout << "sending message!\n\tSize: " << message.size();
			//std::cout << "\n\t i value is : \n" << i << std::endl;
		}
		

		InpQueue.pop_front();
		OutQueue.pop_front();
		#ifdef TIMING
			//time_host_end += omp_get_wtime() - time_host_start
			time_host_end = omp_get_wtime() - time_host_start;
		#endif
  		//printf("Returning from kernel\n");

  		////////////////////////////////////////////////////////////////////
  		// Stats 
  		////////////////////////////////////////////////////////////////////

		#ifdef TIMING

		#ifdef DEBUG
			std::cout << "Timing calculations for loop:\n";
		#endif

			// in_mem_transfer_event, out_mem_transfer_event, kernel_event, read_mem_transfer_event;

			//Inp buffer timing
  			clGetEventProfilingInfo(in_mem_transfer_event.get(), CL_PROFILING_COMMAND_START, sizeof(time_start), &time_start, NULL);
  			clGetEventProfilingInfo(in_mem_transfer_event.get(), CL_PROFILING_COMMAND_END, sizeof(time_end), &time_end, NULL);
  			//nanoSeconds = time_end-time_start;
			//(cl_double)(end - start)*(cl_double)(1e-06);
			#ifdef ACC_TIME
				t_in_mem += (cl_double)(time_end-time_start)*(cl_double)(1e-06);
			#endif
  			std::cout << "\tOpenCl Inp Buffer write time: " << (cl_double)(time_end-time_start)*(cl_double)(1e-06) << " milliseconds\n";

			//Outp buffer timing
			clGetEventProfilingInfo(out_mem_transfer_event.get(), CL_PROFILING_COMMAND_START, sizeof(time_start), &time_start, NULL);
            clGetEventProfilingInfo(out_mem_transfer_event.get(), CL_PROFILING_COMMAND_END, sizeof(time_end), &time_end, NULL);
            //nanoSeconds = time_end-time_start;
            #ifdef ACC_TIME
				t_out_mem += (cl_double)(time_end-time_start)*(cl_double)(1e-06);
			#endif
           	std::cout<<"\tOpenCl Outp Buffer write time: " << (cl_double)(time_end-time_start)*(cl_double)(1e-06) << " milliseconds\n";

			//Kernel timing
			clGetEventProfilingInfo(kernel_event.get(), CL_PROFILING_COMMAND_START, sizeof(time_start), &time_start, NULL);
            clGetEventProfilingInfo(kernel_event.get(), CL_PROFILING_COMMAND_END, sizeof(time_end), &time_end, NULL);
			#ifdef ACC_TIME
				t_kernel += (cl_double)(time_end-time_start)*(cl_double)(1e-06);
			#endif
			std::cout << "\tOpenCl Kernel time: " << (cl_double)(time_end-time_start)*(cl_double)(1e-06) << " milliseconds\n"; 
			
			//read_mem_transfer_event
            clGetEventProfilingInfo(read_mem_transfer_event.get(), CL_PROFILING_COMMAND_START, sizeof(time_start), &time_start, NULL);
            clGetEventProfilingInfo(read_mem_transfer_event.get(), CL_PROFILING_COMMAND_END, sizeof(time_end), &time_end, NULL);
            //nanoSeconds = time_end-time_start;
            #ifdef ACC_TIME
				t_read_mem += (cl_double)(time_end-time_start)*(cl_double)(1e-06);
            #endif
			std::cout << "\tOpenCL read back buffer time: " << (cl_double)(time_end-time_start)*(cl_double)(1e-06) << " milliseconds\n";
			//Host timing
			#ifdef ACC_TIME
				t_host += time_host_end;
			#endif
			std::cout << "\tTime spent in hostcode (ncluding waiting for queue to finish): " << time_host_end 
						  << std::endl;

		#endif
		#ifdef DEBUG
			std::cout << "Finished going back for loop\n";
		#endif
	}
	//#ifdef DEBUG
		std::cout << "Done with main loop, posting end message,  press enter to exit\n";
		serv.PostEndMessage();
	
		std::cin.get();
	//#endif
	#ifdef ACC_TIME
		std::cout << "\tOpenCl total Inp Buffer write time: " << t_in_mem << " milliseconds\n";
		std::cout << "\tOpenCl Outp Buffer write time: " << t_out_mem << " milliseconds\n";
		std::cout << "\tOpenCl Kernel time: " << t_kernel << " milliseconds\n";
		std::cout << "\tOpenCL read back buffer time: " << t_read_mem << " milliseconds\n";
		std::cout << "\tTime spent in hostcode (Includes waiting for QueueFinish): " << t_host << "milliseconds\n" << std::endl;
	#endif
	serv.Stop();
	return 0;
}

