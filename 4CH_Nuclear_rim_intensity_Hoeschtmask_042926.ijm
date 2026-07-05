//Written by William Chadwick and Sunandini Chandra 10.3.25; modified from NC_ratio_macro

//Source directory has raw micrograph files
dir1 = getDirectory("Choose Source Directory");
list = getFileList(dir1);
//Array.print(list);
//Change file extension for other files types
list = Array.filter(list, ".tif");
//Generates folders for results, can change names in lines below without problems later
folder1 = dir1 + File.separator + "Rims";
folder2 = dir1 + File.separator + "results";
File.makeDirectory(folder1);
File.makeDirectory(folder2);

//pre-processing block iterates through each file in list one at a time
for (i=0; i<list.length; i++){
	path = dir1 + list[i];
	//Bio-Formats Importer settings can be changed here but might affect analysis
	run("Bio-Formats Importer", "open=[" + path  + "] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	filename = list[i];
	imagename = File.nameWithoutExtension;
	//run("Z Project...", "projection=[Max Intensity]");
	run("Split Channels");
	//2 channel RL2-Nup96
	//selectWindow("C1-" + filename);
	//4 channel RL2-mCh-Nup96-DAPI
	selectWindow("C4-" + filename);
	run("Duplicate...", " ");
	//threshold for 500kPa cells, manually determine and change values below
	setThreshold(160, 65535, "raw");
	//Create mask of nucleus
	run("Convert to Mask");
	run("Duplicate...", " ");
	//2 channel RL2-Nup96
	//selectWindow("C1-" + imagename + "-2.nd2");
	//4 channel RL2-mCh-Nup96-DAPI
	selectWindow("C4-" + imagename + "-2.tif");
	//erode function to create smaller ROI inside nuclear envelope
	run("Erode");
	run("Erode");
	//subtraction to create a ring of pixels instead of a solid blob
	imageCalculator("Subtract create", "C4-" + imagename + "-1.tif", "C4-" + imagename + "-2.tif");
	//dilation function to clean up edges and create more accurate overlay
	//run("Dilate");
	run("Dilate");
	//watershed if cells are touching, usually doesn't work so try and use data with non-adjoining cells if possible
	//run("Watershed");
	//Create ROI of nuclear mask, 2000-Infinity pixels will capture most nuclear rims but will depend on input data
	run("Analyze Particles...", "size=2000-Infinity pixel clear overlay add composite");
	//Saves intermediary png for easy visualization of masks
	saveAs("PNG", folder1 + File.separator + "Rim_of_" + list[i]);
	//2 channel RL2-Nup96
	//selectImage("C1-" + filename);
	//4 channel RL2-mCh-Nup96-DAPI
	
	//Measures and saves intensities in channel 3
	selectImage("C3-" + filename);
	//saves ROI of rim
	roiManager("save", folder1 + File.separator + "RimROI_of_" + list[i] + ".zip");
	roiManager("Deselect");
	roiManager("Measure");
	//Change name of file below as desired, leaving .csv intact
	saveAs("results", folder2 + File.separator + list[i] + "_Nup62.csv");
	run("Clear Results");
	//Repeats measurement and save for channel 1
	selectImage("C1-" + filename);
	roiManager("Deselect");
	roiManager("Measure");
	saveAs("results", folder2 + File.separator + list[i] + "_RL2.csv");
	//Closes all windows in preparation for next iteration
	close("*");
	roiManager("reset");
}