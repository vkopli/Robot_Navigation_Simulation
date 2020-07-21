# Robot_Navigation_Simulation

## Summary
This is a 2D interactive path-planning simulation for Breadth First Search (“Grassfire Algorithm”). You can design your own obstacle course for the robot by choosing the dimensions of the course, adding/removing barriers, and selecting the start and target points. You can save your custom maps to the software for continued use in the next session, or just stick to the default maps provided.

As you watch the robot navigate the course, you can change the speed of the simulation. You can also choose between the full view of the map and the robot's view (blacking out every block except what the robot has discovered). 

![dark_mode](https://user-images.githubusercontent.com/26824976/88107499-2aecde00-cb75-11ea-9969-62e5afcd092a.png)
![edit_map](https://user-images.githubusercontent.com/26824976/88107788-bcf4e680-cb75-11ea-9be5-5a220213ea1a.png)

## Instructions to Run
Run the "Launch_Interface.m" script to launch the GUI.

## Considerations
The design focus of this UI was on ease of use and flexibility. When adding barriers, a brown block follows your cursor to the location it would be dropped if you were to click. The larger the dimensions of the course, the more ant-like the robot becomes, creating interesting opportunities for creative obstacle course design. You can become a devil's advocate for the path-planning algorithm, trying to "trick" it into making bad decisions. Interfaces like these can be useful in understanding where different classes of path-planning algorithms succeed and where they fail.
