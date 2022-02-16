# 2dTracking

Goal: Track cells in 2d and write the coordinates of their paths to an excel file.

Videos are analyzed frame by frame, and the positions of cells are compared to the positions in the previous frame.

Collision handling: when cells get too close, the algorithm stops tracking the cells until they move apart.  Then, they are tracked as new cells.

main.cpp is the latest version which automates many processes that would otherwise be a headache for humans to do.
