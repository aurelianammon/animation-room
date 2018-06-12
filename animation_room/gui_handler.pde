public void gui_init() {

	cp5 = new ControlP5(this);
    depth_range = cp5.addRange("depth controller")
        // disable broadcasting since setRange and setRangeValues will trigger an event
        .setBroadcast(false) 
        .setPosition(0,0)
        .setSize(400,50)
        .setHandleSize(20)
        .setRange(0,4500)
        .setRangeValues(lowerThreshold,upperThreshold)
        // after the initialization we turn broadcast back on again
        .setBroadcast(true)
        .setColorForeground(color(255,40))
        .setColorBackground(color(255,40))
        ;

    horizontal_range = cp5.addRange("horizontal controller")
        // disable broadcasting since setRange and setRangeValues will trigger an event
        .setBroadcast(false) 
        .setPosition(0,60)
        .setSize(400,50)
        .setHandleSize(20)
        .setRange(0,512)
        .setRangeValues(leftThreshold,rightThreshold)
        // after the initialization we turn broadcast back on again
        .setBroadcast(true)
        .setColorForeground(color(255,40))
        .setColorBackground(color(255,40))
        ;

    vertical_range = cp5.addRange("vertical controller")
        // disable broadcasting since setRange and setRangeValues will trigger an event
        .setBroadcast(false) 
        .setPosition(0,120)
        .setSize(400,50)
        .setHandleSize(20)
        .setRange(0,424)
        .setRangeValues(topThreshold,bottomThreshold)
        // after the initialization we turn broadcast back on again
        .setBroadcast(true)
        .setColorForeground(color(255,40))
        .setColorBackground(color(255,40))
        ;

    sensibility_slider = cp5.addSlider("sensibility controller")
    	// disable broadcasting since setRange and setRangeValues will trigger an event
    	.setBroadcast(false) 
		.setPosition(0,240)
		.setSize(400,50)
		.setRange(0,1)
		.setValue(sensibility)
		.setHandleSize(20)
		// after the initialization we turn broadcast back on again
		.setBroadcast(true)
		.setColorForeground(color(255,40))
        .setColorBackground(color(255,40))
		;

    save_button = cp5.addButton("save_xml")
        .setBroadcast(false) 
        //Set the position of the button : (X,Y)
        .setPosition(0,180)
        //Set the size of the button : (X,Y)
        .setSize(80,50)
        //Set the pre-defined Value of the button : (int)
        .setValue(0)
        //set the way it is activated : RELEASE the mouseboutton or PRESS it
        .activateBy(ControlP5.PRESS)
        .setLabel("Save")
        .setBroadcast(true)
        ;

    load_button = cp5.addButton("load_xml")
        .setBroadcast(false) 
        //Set the position of the button : (X,Y)
        .setPosition(90,180)
        //Set the size of the button : (X,Y)
        .setSize(80,50)
        //Set the pre-defined Value of the button : (int)
        .setValue(0)
        //set the way it is activated : RELEASE the mouseboutton or PRESS it
        .activateBy(ControlP5.PRESS)
        .setLabel("Load")
        .setBroadcast(true)
        ;

    cal_start_button = cp5.addButton("cal_start")
        .setBroadcast(false) 
        //Set the position of the button : (X,Y)
        .setPosition(180,180)
        //Set the size of the button : (X,Y)
        .setSize(80,50)
        //Set the pre-defined Value of the button : (int)
        .setValue(0)
        //set the way it is activated : RELEASE the mouseboutton or PRESS it
        .activateBy(ControlP5.PRESS)
        .setLabel("Start Pos")
        .setBroadcast(true)
        ;

    cal_end_button = cp5.addButton("cal_end")
        .setBroadcast(false) 
        //Set the position of the button : (X,Y)
        .setPosition(270,180)
        //Set the size of the button : (X,Y)
        .setSize(80,50)
        //Set the pre-defined Value of the button : (int)
        .setValue(0)
        //set the way it is activated : RELEASE the mouseboutton or PRESS it
        .activateBy(ControlP5.PRESS)
        .setLabel("End Pos")
        .setBroadcast(true)
        ;

    start_stop_button = cp5.addButton("start_stop")
        .setBroadcast(false) 
        //Set the position of the button : (X,Y)
        .setPosition(360,180)
        //Set the size of the button : (X,Y)
        .setSize(80,50)
        //Set the pre-defined Value of the button : (int)
        .setValue(0)
        //set the way it is activated : RELEASE the mouseboutton or PRESS it
        .activateBy(ControlP5.PRESS)
        .setLabel("Start")
        .setBroadcast(true)
        ;
             
    noStroke();
}