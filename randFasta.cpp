#include <iostream>
#include <fstream>
#include <string>

using namespace std;

int main(int argc, char* argv[]) {
	//CREATE RANDOM INPUT
	//char a[INPUT_SIZE + (4 - INPUT_SIZE % 4)];
	char* a;
	a = new char[atoi(argv[1])];
	srand(time(NULL));
	//cout << "a INPUT_SIZE = " << INPUT_SIZE + (4 - INPUT_SIZE % 4) << endl;
	//for(unsigned int i = 0; i < INPUT_SIZE + (4 - INPUT_SIZE % 4); ++i) {
	for(unsigned int i = 0; i < atoi(argv[1]); ++i) {
		int x = rand() % 4;
		switch(x) {
			case 0:
				a[i] = 'A';
				break;
			case 1:
				a[i] = 'C';
				break;
			case 2:
				a[i] = 'G';
				break;
			case 3:
				a[i] = 'T';
				break;
			default:
				break;
		}
	}

	ofstream f;
	string s = "rand" + to_string(atoi(argv[1]));
	s = s + ".fasta";
	f.open(s);
	for(unsigned int i = 0; i < atoi(argv[1]); ++i) {
		f << a[i];
	}

	delete [] a;
	return 0;
}
