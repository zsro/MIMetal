#pragma once
#include <vector>
//#include <QString>
using namespace std;
class ObjTransToBinary {
    struct Vector3f {
        float x;
        float y;
        float z;
    };

    struct FacePoint {
        vector<int> index;
    };
    struct Face {
        vector<FacePoint> points;
        bool isQuad;
    };
  public:
    ObjTransToBinary();
    ~ObjTransToBinary();
    bool ObjTransfer(const char * inputFilePath, vector<float> * vs, vector<float> * vns, vector<float> * vts, vector<unsigned int> * face);
  private:
    vector<Face> faceList;
    vector<Vector3f> vertexArr;
    vector<Vector3f> normalArr;
    vector<Vector3f> textureArr;

};

