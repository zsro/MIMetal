
#include "ObjTransToBinary.h"
#include <iostream>
#include <sstream>
#include <fstream>
#include <vector>
using namespace std;

ObjTransToBinary::ObjTransToBinary() {

}


ObjTransToBinary::~ObjTransToBinary() {
    faceList.clear();
    vertexArr.clear();
    normalArr.clear();
    textureArr.clear();
}
//inline std::vector<std::string> split(std::string str, std::string pattern) {
//    std::string::size_type pos;
//    std::vector<std::string> result;
//    //str += pattern;//扩展字符串以方便操作
//    int size = int(str.size());
//    //cout << str << endl;
//    for (int i = 0; i < size; i++) {
//        pos = str.find(pattern, i);
//        if (pos < size) {
//            std::string s = str.substr(i, pos - i);
//            //cout<<"split:" << s << endl;
//            result.push_back(s);
//            i = pos + pattern.size() - 1;
//        } else {
//            std::string s = str.substr(i, size - i);
//            //cout << "asplit:" << s << endl;
//            result.push_back(s);
//            break;
//        }
//
//    }
//    return result;
//}


bool ObjTransToBinary::ObjTransfer(const char * inputFilePath, vector<float> * vs, vector<float> * vns, vector<float> * vts, vector<unsigned int> * face) {
    
    ifstream inputFile;
    inputFile.open(inputFilePath);
    FILE *f = fopen(inputFilePath, "r");
    size_t estimateVerticesNumber = 35000;
    char type[32];

    vs->reserve(estimateVerticesNumber * 3);
    vts->reserve(estimateVerticesNumber * 2);
    vns->reserve(estimateVerticesNumber * 3);
    
    char ignore[512];
    float if1, if2, if3;
    float totalPositionX = 0, totalPositionY = 0, totalPositionZ = 0;
    int x = 0;
    while (fscanf(f, "%s", type) != EOF) {
        if (strcmp("v", type) == 0) {
            fscanf(f, "%f%f%f", &if1, &if2, &if3);
            vs->push_back(if1);
            vs->push_back(if2);
            vs->push_back(if3);
            totalPositionX += if1;
            totalPositionY += if2;
            totalPositionZ += if3;
        } else if (strcmp("vt", type) == 0) {
            fscanf(f, "%f%f", &if1, &if2);
            vts->push_back(if1);
            vts->push_back(1 - if2);
        } else if (strcmp("vn", type) == 0) {
            fscanf(f, "%f%f%f", &if1, &if2, &if3);
            vns->push_back(if1);
            vns->push_back(if2);
            vns->push_back(if3);
        } else if (strcmp("f", type) == 0) {
            x++;
            int v1,v2,v3,vt1,vt2,vt3,vn1,vn2,vn3;
            
            fscanf(f, "%d/%d/%d", &v1, &vt1, &vn1);
            fscanf(f, "%d/%d/%d", &v2, &vt2, &vn2);
            fscanf(f, "%d/%d/%d", &v3, &vt3, &vn3);
            face->push_back(v1-1);
            face->push_back(v2-1);
            face->push_back(v3-1);
//            face->push_back(vt);
//            face->push_back(vn);
        } else {
            fgets(ignore, sizeof(ignore), f);
        }
    }
//    printf("--------  ==    %d    ==   ---------",x);
    inputFile.close();

    return true;
}

