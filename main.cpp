//
//  main.cpp
//  CellTracking
//
// add erase + swap to get rid of shorter data sequences
#include "opencv2/opencv.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include "opencv2/objdetect/objdetect.hpp"
#include "opencv2/highgui/highgui.hpp"
#include "include_cpp/libxl.h"
#include <iostream>
#include <fstream>
#include <string>
#include <unistd.h>
#include <math.h>

using namespace cv;
using namespace std;
using namespace libxl;

#define numCells 1200

bool compareCont(vector<Point> contour1, vector<Point> contour2){
    double i = contourArea(contour1,false);//always want area to be positive, dont want oriented area
    double j = contourArea(contour2,false);
    return (i > j);
}

struct rgb{
    char r;
    char g;
    char b;
};

int main(int argc, char** argv){
    // put the video name here:
    String videoName = "Directed Motility Trial 2 4-1-21.avi";
    // set the path to the folder with the videos:
    String path = "/Users/Maximus/Documents/3dscope/Videos/";
    
    //output to excel sheet
    Book* book = xlCreateXMLBook();
    Sheet* sheet = book->addSheet("Sheet1");
    Format* format = book->addFormat();
    format->setBorderBottom();
    
    //get image
    Size size(1000,700);
    VideoCapture capture(path+videoName);
    VideoCapture capture2(path+videoName);
    Mat frame;
    if(!capture.isOpened())
        throw "Error when reading steam_avi";
    namedWindow("raw",0);
    namedWindow("processed",0);

    vector<vector<Point> > contours;
    std::vector<cv::Vec4i> hierarchy;
    Point2f center;
    float radius = 0;

    vector<vector<Point> > cells(numCells);

    //end of tracking a single cell
    Point2f end(-1, -1);

    //for display coloring
    rgb colors[numCells];
    for(int i = 0; i < numCells; i++){
        colors[i].r = (rand() % 200) + 50;
        colors[i].g = (rand() % 200)  + 50;
        colors[i].b = (rand() % 200) + 50;
    }
    while(1)
    {
        //for display
        Mat processed(size.height,size.width, CV_8UC3, Scalar(255,255,255));
        capture >> frame; //get an image from the video
        if(frame.empty())
            break;
        resize(frame,frame,size);
        Mat saveFrame = frame.clone();
        cvtColor(saveFrame,saveFrame, COLOR_BGR2GRAY);
        cvtColor(saveFrame,saveFrame, COLOR_GRAY2RGB);
        imshow("raw",frame); //print out the image
        cvtColor(frame,frame, COLOR_BGR2GRAY); // greyscale
        GaussianBlur(frame,frame,Size(7,7),0,0); // gaussian blur
        adaptiveThreshold(frame,frame,255,ADAPTIVE_THRESH_MEAN_C,THRESH_BINARY,7,3); // threshold
        findContours(frame,contours,hierarchy,RETR_LIST,RETR_TREE);//allows only key points to be added
        if(contours.size() > 0)
          sort(contours.begin(),contours.end(),compareCont);
              //get cells that disappeared
              vector<bool> present(cells.size(),false);
              for(int i = 0; i < cells.size(); i++){
                  if(cells[0].size() == 0 || cells[0].back().x == -1){
                       present[i] = true;//already registered cell has disappeared, or cell has not yet been registered
                   }
              }
        //main loop to process each contour
        for(int i = 0; i < contours.size() && contourArea(contours[i]) > 5; i++)
        {
            minEnclosingCircle(contours[i],center,radius);
            //cout << center << endl;
            circle(processed, center,6, Scalar(0,0,255),FILLED);//default color when not tracked
            circle(saveFrame, center,15, Scalar(0,0,255),3);
            int possibleIdx = -1;
            //now processing each current cell
            for(int j = 0; j < cells.size(); j++){
                if(cells[j].size() == 0){
                    if(possibleIdx == -1){
                        cells[j].push_back(center);
                        present[j] = true;
                        circle(processed, center,6, Scalar(0,255,0),FILLED);
                        circle(saveFrame, center,15, Scalar(0,0,255),3);
                    }
                    break;
                }
                unsigned long long dist = pow(cells[j].back().x - center.x,2) +
                                          pow(cells[j].back().y - center.y,2);
                if(dist < 2000 && cells[j].back().x != -1){
                    if(possibleIdx != -1){//collision: lost cells
                        //cout << "in" << endl;
                        cells[j].push_back(end);
                        cells[possibleIdx].push_back(end);
                        present[j] = true;
                        present[possibleIdx] = true;
                        possibleIdx = -1;
                        break;
                    }
                    possibleIdx = j;
                }
            }
            if(possibleIdx != -1){
              cells[possibleIdx].push_back(center);
                            circle(processed, center,6, Scalar(255,0,0),FILLED);
                            circle(saveFrame, center,15, Scalar(0,0,255),3);
              present[possibleIdx] = true;
            }
        }
        for(int j = 0; j < present.size(); j++){
             if(!present[j] && cells[j].size() != 0)
                 cells[j].push_back(end);
        }
        //imshow("processed",frame);
        //imshow("processed2",processed);
        imshow("saveFrame",saveFrame);
        waitKey(5); // waits to display frame
    }
    //print out coordinates
    int row = 1;
    for(int i = 1; i < cells.size(); i++){
        // only print data for the cell if it is moving
        int xMin = INT_MAX, xMax = INT_MIN, yMin = INT_MAX, yMax = INT_MIN;
        int pathLength = 0;
        for(int k = 0; k < cells[i].size(); k++){
            if(cells[i][k].x == -1){
                break;
            }
            if(k > 1 && cells[i][k].x == cells[i][k-1].x && cells[i][k].y == cells[i][k-1].y){
                break;
            }
            xMin = min(xMin, cells[i][k].x); xMax = max(xMax, cells[i][k].x);
            yMin = min(yMin, cells[i][k].y); yMax = max(yMax, cells[i][k].y);
            pathLength = k;
        }
        // checks if the largest x difference or largest y difference are both greater than 10.
        // and there are at least 10 coordinates
        if((xMax-xMin > 10 || yMax-yMin > 10) && pathLength > 10){
            string str = "Cell" + to_string(i) + ":";
            sheet->writeStr(row, 0, str.c_str());
            row++;
            for(int j = 0; j < pathLength; j++){
                if(cells[i][j].x == -1){
                    break;
                }
                sheet->writeNum(row, 1, cells[i][j].x);
                sheet->writeNum(row, 2, cells[i][j].y);
                row++;
            }
        }
    }
    // automatically writing text and formuals to the excel sheet
    sheet->writeStr(1, 1, "x");
    sheet->writeStr(1, 2, "y");
    sheet->writeStr(1, 3, "x component");
    sheet->writeFormula(2, 3, "=IF(COUNT(B3:B4)=2,B4-B3,\"\")");
    sheet->writeStr(1, 4, "y component");
    sheet->writeFormula(2, 4, "=IF(COUNT(C3:C4)=2,C4-C3,\"\")");
    sheet->writeStr(1, 5, "normalized x");
    sheet->writeFormula(2, 5, "=IF(COUNT(D3)=1, D3/(SQRT(D3^2+E3^2)), \"\")");
    sheet->writeStr(1, 6, "normalized y");
    sheet->writeFormula(2, 6, "=IF(COUNT(E3)=1, E3/(SQRT(D3^2+E3^2)), \"\")");
    sheet->writeStr(1, 7, "Argument of vector");
    sheet->writeFormula(2, 7, "=IF(COUNT(F3)=1,MOD(ATAN2(F3,G3)+2*PI(), 2*PI()),\"\")");
    sheet->writeStr(1, 8, "Persistence length 1");
    sheet->writeFormula(2, 8, ("=2*STDEV.S(I5:I" + to_string(row) + ")/COUNT(I5:I" + to_string(row) + ")").c_str());
    sheet->writeFormula(3, 8, ("=AVERAGE(I5:I" + to_string(row) + ")").c_str(), format);
    sheet->writeFormula(4, 8, "=IF(COUNT($H3:OFFSET($H3,COLUMN()-8,0,1,1))=COLUMN()-7, COS(OFFSET($H3,COLUMN()-8,0,1,1)-$H3),\"\")");
    sheet->writeFormula(1, 9, "=CONCAT(\"p length \", COLUMN()-8)");
    sheet->setCol(3, 6, 10.5);
    sheet->setCol(7, 7, 14.5);
    sheet->setCol(8, 8, 18);
    book->save((videoName.substr(0, videoName.length()-4) + ".xlsx").c_str());
    book->release();
    waitKey(0);
    return 0;
}
