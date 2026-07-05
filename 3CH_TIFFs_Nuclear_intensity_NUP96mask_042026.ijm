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
	run("Bio-Formats Importer", "open=[" + path  + "] color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	filename = list[i];
	imagename = File.nameWithoutExtension;
	run("Split Channels");
	selectWindow("C3-" + filename);
	run("Duplicate...", " ");
	//threshold for normal and hyper cells, manually determine and change values below
	setThreshold(390, 65535, "raw");
	//threshold for hypo cells, manually determine and change values below
	//setThreshold(160, 65535, "raw");
	//Create mask of nucleus
	run("Convert to Mask");
	//Create ROI of nuclear mask, 10-Infinity pixels will capture most nuclear rims but will depend on input data
	run("Analyze Particles...", "size=10-Infinity pixel exclude clear overlay add composite");
	//Saves intermediary png for easy visualization of masks
	saveAs("PNG", folder1 + File.separator + "Rim_of_" + list[i]);
	
	//Measures and saves intensities in channel 3
	selectImage("C3-" + filename);
	roiManager("Deselect");
	roiManager("Measure");
	//Change name of file below as desired, leaving .csv intact
	saveAs("results", folder2 + File.separator + list[i] + "_Nup96_results.csv");
	run("Clear Results");
	//Repeats measurement and save for channel 2
	selectImage("C2-" + filename);
	roiManager("Deselect");
	roiManager("Measure");
	saveAs("results", folder2 + File.separator + list[i] + "_RL2_results.csv");
	run("Clear Results");
	//Repeats measurement and save for channel 1
	selectImage("C1-" + filename);
	roiManager("Deselect");
	roiManager("Measure");
	saveAs("results", folder2 + File.separator + list[i] + "_OGA_results.csv");
	run("Clear Results");
	//Closes all windows in preparation for next iteration
	close("*");
}