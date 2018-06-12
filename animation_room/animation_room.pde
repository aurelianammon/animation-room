/**
* Processing sketch for Caro's Master Presentation.
* Implementation of the OpenKinect and the OSC library
* to controll Resolume Arena.
*
* The user can controll the visuals by walking into the kinect
* fov and by moving the arms.
*
* @author  Aurelian Ammon
* @version 1.0
* @since   2018-06-08 
*/


/* Open Kinect - library and variables
-------------------------------------------------- */
import org.openkinect.processing.*;

Kinect2 kinect;

//threshold in millimeters
int lowerThreshold = 0;
int upperThreshold = 1500;

//threshold in pixles from the image
int leftThreshold = 0;
int rightThreshold = 512;
int topThreshold = 0;
int bottomThreshold = 424;

// distance restrictions
int start_position = 1500;
int end_position = 500;

int pixel_count = 0; // the amount of active pixels

int[] prevDepthMap; // save previous kinect map


/* controlP5 - library and variables
-------------------------------------------------- */
import controlP5.*;

ControlP5 cp5; // main gui object

// elements
Range depth_range, horizontal_range, vertical_range;
Button save_button, load_button, cal_start_button, cal_end_button, start_stop_button;
Slider sensibility_slider; 


/* osc protocol - library and variables
-------------------------------------------------- */
import oscP5.*; // oscP5 library
import netP5.*; // netP5 library
 
OscP5 oscP5;
NetAddress remoteLocation;

boolean on = false;


/* state - variables
-------------------------------------------------- */

//state definitions
int START   = 0;
int VORHANG = 1;
int VIDEO   = 2;
int END     = 3;

int state = START; // main installation state

boolean isPlaying = false; // is the installation loop running

// is the video at the end or at the start?
boolean start_state = false;
boolean end_state = false;


/* game logic - variables
-------------------------------------------------- */

//avarege distance and movement
int distance_sum = 0;
int distance = 0;
int disturbance_sum = 0;
int disturbance = 0;
float movement = 0;

float video_state = 0; // resolume feedback

float sensibility = 0.5; // movement sensibility

int time = 0; // for time delays


/** 
 * setup the whole processing application
 */
void setup() {

    size(1024, 424, P2D);

    gui_init(); // initializes all gui elements
    load(); // loads the settings from the xml file

    oscP5 = new OscP5(this, 7001); // start library, listen to port 7001
    remoteLocation = new NetAddress("169.254.15.176", 7000); // ip and port to send

    // initialize the open kinect library
    kinect = new Kinect2(this);
    kinect.initDepth();
    kinect.initDevice();

    time = millis(); // set timestamp

    init_resolume(); // initialize resolume videos
}

void draw() {

    background(0);

    PImage img = new PImage(512, 424);
    PImage depthImage = kinect.getDepthImage();
    int[] depthMap = kinect.getRawDepth();
    if (prevDepthMap == null) {
        prevDepthMap = depthMap;
    }

    // reset pixel counters
    distance_sum = 0;
    disturbance_sum = 0;
    pixel_count = 0;

    img.loadPixels(); // pixels must be loaded to edit

    for (int x = 0; x < kinect.depthWidth; x++) {
        for (int y = 0; y < kinect.depthHeight; y++) {
            int loc = x + y * kinect.depthWidth;
            int rawDepth = depthMap[loc];
            int prevRawDepth = prevDepthMap[loc];

            if (rawDepth > lowerThreshold && rawDepth < upperThreshold && x > leftThreshold && x < rightThreshold
                    && y < bottomThreshold && y > topThreshold) {
                img.pixels[loc] = color(150, 50, 50);

                distance_sum = distance_sum + rawDepth;
                disturbance_sum = disturbance_sum + abs(rawDepth - prevRawDepth);
                pixel_count++;
            } 
            else {
                img.pixels[loc] = depthImage.pixels[loc];
            }

            if (pixel_count > 1000) {
                distance =  distance_sum / pixel_count;
                disturbance = (7 * disturbance + disturbance_sum / pixel_count) / 8;
            } else {
                distance = 4500;
                disturbance = 0;
            }

            if (true) {
                if (x < leftThreshold || x > rightThreshold || y > bottomThreshold || y < topThreshold) {
                    img.pixels[loc] = color(0, 0, 0);
                }
            }
        }
    }

    img.updatePixels(); // update the pixels

    if (!isPlaying) {
        image(img, 512, 0);
    }

    prevDepthMap = depthMap;

    update_movement();

    //display movement
    rect(width / 4, height - 100, (width / 4) * 10 * movement(), 50);
    //display position
    rect(0, height - 50, width / 2 * progress(), 50);


    //resolume logic
    if (state == START && isPlaying) { 

        println("start");

        end_state = false;
        start_state = true;

        OscMessage msg;

        msg = new OscMessage("/composition/layers/1/clips/1/connect");
        msg.add(1);
        oscP5.send(msg, remoteLocation);

        msg = new OscMessage("/composition/layers/1/clips/1/transport/position");
        msg.add(0);
        oscP5.send(msg, remoteLocation);

        msg = new OscMessage("/composition/layers/1/clips/1/transport/position/behaviour/playdirection");
        msg.add(2);
        oscP5.send(msg, remoteLocation);

        state = VORHANG;
    }

    if (state == VORHANG) { vorhang(); }
    if (state == VIDEO) { video(); }
    if (state == END) { end(); }

    textSize(20);
    text("CURRENT STATE: " + state + " - FRAMERATE: " + frameRate, 10, 315); 

    //sprintln(frameRate);
}

void init_resolume() {

    OscMessage msg;

    msg = new OscMessage("/composition/layers/1/clips/1/connect");
    msg.add(1);
    oscP5.send(msg, remoteLocation);

    msg = new OscMessage("/composition/layers/1/clips/1/transport/position");
    msg.add(0);
    oscP5.send(msg, remoteLocation);

    msg = new OscMessage("/composition/layers/1/clips/1/transport/position/behaviour/playdirection");
    msg.add(2);
    oscP5.send(msg, remoteLocation);

    msg = new OscMessage("/composition/layers/1/clips/2/transport/position");
    msg.add(0);
    oscP5.send(msg, remoteLocation);

    msg = new OscMessage("/composition/layers/1/clips/2/transport/position/behaviour/playdirection");
    msg.add(2);
    oscP5.send(msg, remoteLocation);   
}

void vorhang() {

    if (time < millis() - 500) {
        OscMessage msg = new OscMessage("/composition/layers/1/clips/1/transport/position");
        msg.add(progress());
        oscP5.send(msg, remoteLocation);  // send message
    }

    if (progress() == 1) {

        state = VIDEO;
        movement = 0;

        OscMessage mesg;

        mesg = new OscMessage("/composition/layers/1/clips/2/connect");
        mesg.add(1);
        oscP5.send(mesg, remoteLocation);

        mesg = new OscMessage("/composition/layers/1/clips/2/transport/position");
        mesg.add(0);
        oscP5.send(mesg, remoteLocation);

        mesg = new OscMessage("/composition/layers/1/clips/2/transport/position/behaviour/playdirection");
        mesg.add(2);
        oscP5.send(mesg, remoteLocation);

        time = millis();
    }
}

void video() {

    OscMessage msg;

    if (time < millis() - 1000 && end_state == false) {
        //just every second
        if (movement() > 0) {

            start_state = false;

            msg = new OscMessage("/composition/layers/1/clips/2/transport/position/behaviour/playdirection");
            msg.add(1);
            oscP5.send(msg, remoteLocation);

            msg = new OscMessage("/composition/layers/1/clips/2/transport/position/behaviour/speed");
            msg.add(movement());
            oscP5.send(msg, remoteLocation);
        } else {

            msg = new OscMessage("/composition/layers/1/clips/2/transport/position/behaviour/playdirection");
            msg.add(0);
            oscP5.send(msg, remoteLocation);

            msg = new OscMessage("/composition/layers/1/clips/2/transport/position/behaviour/speed");
            msg.add(abs(movement()));
            oscP5.send(msg, remoteLocation);
        }
        time = millis();
    }

    // if (video_state > 0.99) {

    //     state = END;

    //     msg = new OscMessage("/composition/layers/1/clips/2/transport/position/behaviour/playdirection");
    //     msg.add(2);
    //     oscP5.send(msg, remoteLocation);
    // }

    if (progress() == 0) {
        state = START;
        init_resolume();
    }
}

void end() {

    if (progress() == 0) {
        state = START;
        init_resolume();
    }
}

public void update_movement() {

    float s_movement = 1; // se
    float factor = map(disturbance, 0, 100, 0, s_movement);

    // movement = movement + (factor - sensibility * (movement * 0.1 + 0.5)) * (1 / frameRate);
    movement = movement + (factor) / frameRate - (movement * 0.1 + sensibility) / frameRate;
    if (movement > 1) {
        movement = 1;
    } else if (movement < -1) {
        movement = -1;
    } else if (start_state == true) {
        movement = 0;
    }
}

public float movement() {

    return movement / 10;
}

public float progress() {
    float result = map(distance, start_position, end_position, 0, 1);
    if (result > 1) {
        result = 1;
    } else if (result < 0) {
        result = 0;
    }

    return result;
}

void controlEvent(ControlEvent theControlEvent) {
    if(theControlEvent.isFrom("depth controller")) {
        // min and max values are stored in an array.
        // access this array with controller().arrayValue().
        // min is at index 0, max is at index 1.
        lowerThreshold = int(theControlEvent.getController().getArrayValue(0));
        upperThreshold = int(theControlEvent.getController().getArrayValue(1));
        println("update depth");
    }

    if(theControlEvent.isFrom("horizontal controller")) {
        // min and max values are stored in an array.
        // access this array with controller().arrayValue().
        // min is at index 0, max is at index 1.
        leftThreshold = int(theControlEvent.getController().getArrayValue(0));
        rightThreshold = int(theControlEvent.getController().getArrayValue(1));
        println("update horizontal");
    }

    if(theControlEvent.isFrom("vertical controller")) {
        // min and max values are stored in an array.
        // access this array with controller().arrayValue().
        // min is at index 0, max is at index 1.
        topThreshold = int(theControlEvent.getController().getArrayValue(0));
        bottomThreshold = int(theControlEvent.getController().getArrayValue(1));
        println("update vertical");
    }

    if(theControlEvent.isFrom("sensibility controller")) {
        // min and max values are stored in an array.
        // access this array with controller().arrayValue().
        // min is at index 0, max is at index 1.
        sensibility = theControlEvent.getController().getValue();
        println("update sensibility" + sensibility);
    }
}

public void save_xml(int theValue) {
    save();
}

public void load_xml(int theValue) {
    load();
}

public void cal_start(int theValue) {
    start_position = distance;
    println("set start value");
}

public void cal_end(int theValue) {
    end_position = distance;
    println("set end value");
}

public void start_stop(int theValue) {
    isPlaying = !isPlaying;

    if(isPlaying) {
        start_stop_button.setLabel("Stop");
    } else {
        start_stop_button.setLabel("Start");
        state = START;
        init_resolume();
    }
}

public void update_controllers() {
    //update all the controller values
    depth_range.setRangeValues(lowerThreshold,upperThreshold);
    horizontal_range.setRangeValues(leftThreshold,rightThreshold);
    vertical_range.setRangeValues(topThreshold,bottomThreshold);
    sensibility_slider.setValue(sensibility);
}

void oscEvent(OscMessage msg) {
    if (msg.addrPattern().equals("/composition/layers/1/clips/2/transport/position")) {
        float value = msg.get(0).floatValue();
        if (value == 0) {
            start_state = true;
        }
        else if (value == 1) {
            end_state = true;
        }
    }
}
