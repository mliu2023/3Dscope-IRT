import cv2
import numpy as np
import matplotlib.pyplot as plt
images = ['diffractionpatternex.jpg', 'dpat.jpeg']
img = cv2.imread(images[1], cv2.IMREAD_GRAYSCALE) #GRAYSCALE grayscales the image
#Other options for IMREAD_GRAYSCALE (0) are IMREAD_COLOR (1) and IMREAD_UNCHANGED (-1)
print(img.shape)
dimentions = img.shape

middleIntensities = []
print(img[dimentions[0]/2])
for x in img[dimentions[0]/2]:
    print(x)
    middleIntensities.append(x)
print(middleIntensities)
cv2.line(img, (0, dimentions[0]/2), (dimentions[1], dimentions[0]/2), (0, 0, 0), 3)
plt.plot(middleIntensities)
plt.ylabel("intensity")
cv2.imshow('image', img)
plt.show()
cv2.waitKey(0)
cv2.destroyAllWindows()
