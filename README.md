# ar_video_overlay_ios
applications for VR and AR, for example, the last application I did was connected just with this. It was a native applications. The essence of the application was that when you open the application in some museum, for example, and hover over the picture(painting), it starts to come to life.  The difficulty was that native ARKIT works only with local files and in order to scale the application, it was necessary to figure out how to work with it, since local files are limited to 100 pictures and this is too difficult. Therefore, we decided to connect ARCORE to the application with its own infrastructure, i.e. we ourselves trained our AI from the web part and then loaded the model locally, which could track and recognize what exactly we are trying to scan or find on the screen, and then loaded the data about this object itself.



https://user-images.githubusercontent.com/8526612/176679963-799bdcf5-067a-4466-8f91-9f90dd244d3f.mp4

