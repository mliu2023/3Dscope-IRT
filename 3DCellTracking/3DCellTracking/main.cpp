// V4


#include <opencv2/opencv.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/objdetect/objdetect.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <iostream>
#include <algorithm>
#include <unistd.h>

using namespace cv;
using namespace std;

#define maxRad 200
#define deltaT 0
#define deltaD 6
#define L 20
#define blurSize 11
#define threshold1 60
#define threshold2 40

struct Radius{
    Point p;
    int dist;
    Radius(Point p, int dist){
        this->p = p;
        this->dist = dist;
    }
};

bool compCont(vector<Point> contour1, vector<Point> contour2){
    // always want area to be positive, don't want oriented area
    // areas sorted in decreasing order
    double i = contourArea(contour1,false);
    double j = contourArea(contour2,false);
    return (i > j);
}

bool compRadius(Radius r1, Radius r2){
    // distances between points and the center sorted in increasing order
    return r1.dist < r2.dist;
}

int main(int argc, char** argv){
    //get image
    String path = "/Users/Maximus/Documents/3dscope/3DTracking/";
    String imageName("dpat.jpg");
    Mat og = imread(path + imageName, IMREAD_COLOR);
    //Mat newIm = og.clone();
    //cvtColor(og,og,COLOR_BGR2GRAY);//grayscale
    //namedWindow("gray",0);
    //imshow("gray",image);
    //make sure input is valid
   if(og.empty()){
       cout <<  "Could not open or find the image" << endl;
       return -1;
   }

    //variables
    vector<vector<Point> > contours;//point has a x and y
    std::vector<cv::Vec4i> hierarchy;
    vector<Point> locations;
    vector<Radius> circles;
    Mat image = og.clone();
    Mat image2 = og.clone();
    cvtColor(image, image, COLOR_BGR2GRAY);
    GaussianBlur(image, image, Size(blurSize, blurSize), 0, 0);
    Canny(image, image, threshold1, threshold2);
    findContours(image, contours, hierarchy, RETR_LIST, RETR_TREE);
    Moments m = moments(image, true); // true because image is a binary image
    Point centroid(m.m10/m.m00, m.m01/m.m00);
    circle(image2, centroid, 0, Scalar(0, 0, 0), -1);
    findNonZero(image, locations);
    cout << contours.size() << endl;

    for(Vector<Point> cont : contours){
        float minVariance = INT_MAX; Point bestCenter(0,0); float bestRadius = 0;
        for(int r = max(centroid.x-L, 0); r <= min(centroid.x+L, image.rows); r++){
            for(int c = max(centroid.y-L, 0); c <= min(centroid.y+L, image.cols); c++){
                float total = 0;
                float totalVar = 0;
                for(Point p : cont){
                    total += sqrt((r-p.x)*(r-p.x)+(c-p.y)*(c-p.y));
                }
                float avgRadius = total/(cont.size());
                for(Point p : cont){
                    totalVar += pow((avgRadius - sqrt((r-p.x)*(r-p.x)+(c-p.y)*(c-p.y))), 2);
                }
                if(totalVar/(cont.size()-1) < minVariance){
                    minVariance = totalVar/(cont.size()-1);
                    bestCenter = Point(r,c);
                    bestRadius = avgRadius;
                }
            }
        }
        if((float)contours.size()/(2*3.14159*bestRadius) > deltaT){
            circle(image2, bestCenter, bestRadius, Scalar(255, 0, 0));
        }
    }
    /*
    vector<Radius> radArr;
    vector<int> prefixArr;
    for(Point p : locations){
        int dist = (int)sqrt((p.x-centroid.x)*(p.x-centroid.x) + (p.y-centroid.y)*(p.y-centroid.y));
        radArr.push_back(Radius(p, dist));
    }
    sort(radArr.begin(), radArr.end(), compRadius);
    for(int l = 0; l < locations.size(); l++){
        locations[l] = radArr[l].p;
    }
    prefixArr.push_back(0);
    for(int k = 0; k < radArr.size(); k++){
        prefixArr.push_back(prefixArr[k] + radArr[k].dist);
    }
    int i = 1;
    int j = 2;
    while(j < radArr.size()){
        int meanDist = (prefixArr[j] - prefixArr[i])/(j-i);
        if(abs(meanDist - radArr[j].dist) > deltaD || abs(radArr[j].dist - radArr[j-1].dist) > deltaD){
            float R = (float)(j-i)/(2*3.14159*meanDist);
            cout << R << endl;
            if(R <= deltaT){
                i = j;
                j = j+1;
            }
            else{
                vector<Point>::iterator ith = locations.begin() + i;
                vector<Point>::iterator jth = locations.begin() + j;
                vector<Point> circ(ith, jth);
                Moments mCircle = moments(circ);
                Point centroidCircle(mCircle.m10/mCircle.m00, mCircle.m01/mCircle.m00);
                float totalDist = 0;
                for(Point p : circ){
                    totalDist += sqrt((centroidCircle.x-p.x)*(centroidCircle.x-p.x) + (centroidCircle.y-p.y)*(centroidCircle.y-p.y));
                }
                circles.push_back(Radius(centroidCircle, (int)(totalDist/(j-i))));
                i = j;
                j = j+1;
            }
        }
        else{
            j = j+1;
        }
    }
    for(Radius r : radArr){
        cout << r.dist << endl;
    }
    for(int p : prefixArr){
        cout << p << endl;
    }
    cout << radArr.size() << endl;
    cout << prefixArr.size() << endl;
    for(Radius drawCircle: circles){
        circle(image2, drawCircle.p, drawCircle.dist, Scalar(255, 0, 0));
    }
    */
    namedWindow("contours", false);
    imshow("contours", image);
    namedWindow("circles", false);
    imshow("circles", image2);
    //namedWindow("contours",0);
    //imshow("contours",newIm);
    waitKey(0);
    return 0;
}
