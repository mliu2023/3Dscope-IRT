//V1.2

#include <opencv2/opencv.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/objdetect/objdetect.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <iostream>
#include <fstream>
#include <unistd.h>
#include <math.h>

using namespace cv;
using namespace std;

#define numCells 3000

//allows us to sort contours by area
bool compCont(vector<Point> contour1, vector<Point> contour2){
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
		// output file
		ofstream fout("chlamy 4.out");
    //get image
    Size size(1000,700);
    String videoName = "chlamy 4.avi";
    VideoCapture capture(videoName);//to read in each image
		VideoCapture capture2(videoName);
    Mat frame;
    if(!capture.isOpened())
        throw "Error when reading steam_avi";
    namedWindow("raw",0);
    namedWindow("processed",0);

    vector<vector<Point> > contours;
    std::vector<cv::Vec4i> hierarchy;
    Point2f center;
    float radius = 0;

    vector<vector<Point> > cells(numCells);//dimensions: cell #, time (by frame)    (value contained is location for given cell # at given time)

		//end of tracking a single cell
    Point2f end(-1, -1);
    int count = 0;

		//for display coloring
		rgb colors[numCells];
		for(int i = 0; i < numCells; i++){
			colors[i].r = (rand() % 200) + 50;
			colors[i].g = (rand() % 200)  + 50;
			colors[i].b = (rand() % 200) + 50;
		}

		int c = 0;//# of frames we read in, or alternatively, # of time we went through the while loop
    while(1)
    {
			  c++;
				if(c % 50 == 0)
					cout << "count:" << c;
				if(c == 500)
					break;
			  //for display
			  Mat processed(size.height,size.width, CV_8UC3, Scalar(255,255,255));
        capture >> frame;//get an image from the video
        if(frame.empty())
            break;
        resize(frame,frame,size);
        imshow("raw",frame);//print out the image
        cvtColor(frame,frame, COLOR_BGR2GRAY);//convert to grayscale
        GaussianBlur(frame,frame,Size(7,7),0,0);//blur
        adaptiveThreshold(frame,frame,255,ADAPTIVE_THRESH_MEAN_C,THRESH_BINARY,7,3);//theshold: adaptive to maintain boundaries
        findContours(frame,contours,hierarchy,RETR_LIST,RETR_TREE);//to minimize memory usage, parameters for allowing only key points of contours to be added
				//sort contours by size
				if(contours.size() > 0)
          sort(contours.begin(),contours.end(),compCont);
		  	//record which cells are active (meaning they have not yet "disappeared" and they have been recorded)
		  	vector<bool> present(cells.size(),false);
	  		for(int i = 0; i < cells.size(); i++){
  				if(cells[i].size() == 0 || cells[i].back().x == -1){
 	  				present[i] = true;
   				}
	  		}
        //main loop to process each contour
        for(int i = 0; i < contours.size() && contourArea(contours[i]) > 5; i++)//for every contour w/ sufficient area; took out parameter comparing % of min enclosing circle filled to see if our contour is a circle
         {
					 //we want to add this contour to our 2d cell array
            minEnclosingCircle(contours[i],center,radius);//get center of contour
            circle(processed, center,25, Scalar(0,0,255));//printing out the outer ring
            int possibleIdx = -1;//for collisions
            //now processing each current cell: iterate through all cells in our cells array to see where this current cell belongs to
            for(int j = 0; j < cells.size(); j++){
							//this means our cell isn't in close proximity w/ cells in prior frame --> we have a new cell
              if(cells[j].size() == 0){
								if(possibleIdx == -1){
	                cells[j].push_back(center);
									present[j] = true;
									circle(processed, center,6, Scalar(0,255,0),FILLED);
							  }
								break;
              }
							unsigned long long a;
							a = pow(cells[j].back().x - center.x,2) + pow(cells[j].back().y - center.y,2);
							//check to see if cell is in proximity of past cells
							if(a < 625 && cells[j].back().x != -1 && !present[j]){
								//cout << "(" << cells[j].back().x << "," << cells[j].back().y << ")" << "(" << center.x << "," << center.y << ")" << endl;
								circle(processed, center,6, Scalar(255,0,0),FILLED);
								if(possibleIdx != -1){//collision (meaning our current cell could belong to multiple past cells): lost cells
									circle(processed, center,6, Scalar(0,0,255),FILLED);
                  //cells[j].push_back(end);
									//erase cells w/ less than 4 points b/c these aren't helpful
									if(cells[j].size() < 4){
										present.erase(present.begin() + j);
										present.resize(present.size() + 1);
										cells.erase(cells.begin() + j);
										cells.resize(cells.size() + 1);
										j--;
									}
                  //cells[possibleIdx].push_back(end);
									if(cells[possibleIdx].size() < 4){
										present.erase(present.begin() + possibleIdx);
										present.resize(present.size() + 1);
										cells.erase(cells.begin() + possibleIdx);
										cells.resize(cells.size() + 1);
										j--;
									}
                  possibleIdx = -1;
                  break;
                }
                possibleIdx = j;
              }
            }
            if(possibleIdx != -1){//we connected our cell w/ a cell in prior frame w/o any collision --> add this new coordinate to cell
              cells[possibleIdx].push_back(center);
              present[possibleIdx] = true;
            }
         }
				 //for prior cells that weren't connected to cells in new frame; we need to end these cells (they prob disappeared or collided)
				 for(int j = 0; j < present.size(); j++){
					 if(!present[j] && cells[j].size() != 0){
					   cells[j].push_back(end);
					 }
				 }
        imshow("processed",processed);
        waitKey(5); // waits to display frame
    }
		//print out x coordinates
    fout << cells.size() << endl;
    for(int i = 0; i < cells.size(); i++){
			fout << "Cell" << i << ":" << endl;
      for(int j = 0; j < cells[i].size(); j++){
        if(cells[i][j].x == -1)
          break;
        //cout << "(" << cells[i][j].x << "," << cells[i][j].y << ")" << endl;
				fout << cells[i][j].x << endl;
      }
    }
		//print out y coordinates
		for(int i = 0; i < cells.size(); i++){
			fout << "Cell" << i << ":" << endl;
			for(int j = 0; j < cells[i].size(); j++){
				if(cells[i][j].x == -1)
					break;
				//cout << "(" << cells[i][j].x << "," << cells[i][j].y << ")" << endl;
				fout << cells[i][j].y << endl;
			}
		}
		fout.close();
    //checking work
		/*capture2 >> frame;
		resize(frame,frame,size);
		imshow("raw",frame);
		cvtColor(frame,frame, COLOR_BGR2GRAY);
		GaussianBlur(frame,frame,Size(7,7),0,0);
		adaptiveThreshold(frame,frame,255,ADAPTIVE_THRESH_MEAN_C,THRESH_BINARY,7,3);
		for(int i = 0; i < cells.size(); i++){
			circle(frame, cells[i][0],6, Scalar(125),FILLED);
		}
		imshow("processed",frame);*/
    waitKey(0);
  	return 0;
}
