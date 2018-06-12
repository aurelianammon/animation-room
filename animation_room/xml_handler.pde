public void save(String filename) {

	XML root = new XML("settings");

	// create XML elements for each surface containing the resolution
	// and control point data
	XML variables = new XML("variables");
	variables.setInt("lowerThreshold", lowerThreshold);
	variables.setInt("upperThreshold", upperThreshold);
	variables.setInt("leftThreshold", leftThreshold);
	variables.setInt("rightThreshold", rightThreshold);
	variables.setInt("topThreshold", topThreshold);
	variables.setInt("bottomThreshold", bottomThreshold);
	variables.setInt("start_position", start_position);
	variables.setInt("end_position", end_position);
	variables.setFloat("sensibility", sensibility);

	root.addChild(variables);

	saveXML(root, filename);
	println("settings: layout saved to " + filename);
}

/**
 * Saves the current layout into "settings.xml"
 */
public void save() {
	save("settings.xml");
}

/**
 * Loads a saved layout from a given XML file
 */
public void load(String filename) {
	XML root = loadXML(filename);
	
	/*
	// Guy's version -- need to figure out why this doesn't work
	surfaces.clear();
	for (int i=0; i < root.getChildCount(); i++) {
		XML surfaceEl = root.getChild(i);
		int w = surfaceEl.getInt("w");
		int h = surfaceEl.getInt("h");
		int res = surfaceEl.getInt("res");
		CornerPinSurface surface = createCornerPinSurface(w, h, res);
		surface.load(surfaceEl);
	}
	*/
	
	XML variablesXML = root.getChild(1);

	lowerThreshold = variablesXML.getInt("lowerThreshold");
	upperThreshold = variablesXML.getInt("upperThreshold");
	leftThreshold = variablesXML.getInt("leftThreshold");
	rightThreshold = variablesXML.getInt("rightThreshold");
	topThreshold = variablesXML.getInt("topThreshold");
	bottomThreshold = variablesXML.getInt("bottomThreshold");
	start_position = variablesXML.getInt("start_position");
	end_position = variablesXML.getInt("end_position");
	sensibility = variablesXML.getFloat("sensibility");

	update_controllers();

	println("settings: layout loaded from " + filename);
}

/**
 * Loads a saved layout from "settings.xml"
 */
public void load() {
	load("settings.xml");
}
