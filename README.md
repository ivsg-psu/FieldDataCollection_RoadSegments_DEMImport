# FieldDataCollection_RoadSegments_DEMImport

<!--
The following template is based on:
Best-README-Template
Search for this, and you will find!
>
<!-- PROJECT LOGO -->

## FieldDataCollection_RoadSegments_DEMImport

![main laps picture](./Images/testTrackDEM_Intensity.png)

The purpose of this code is to support the import of Digital Elevation Maps (DEMs). Typically, these are obtained from the PASDA website at: 

[PASDA website](https://pasda.maps.arcgis.com/apps/webappviewer/index.html?id=f8b951ee77094a81a0a3d6eaa824ebdd)

<!-- a href="https://github.com/ivsg-psu/FeatureExtraction_Association_PointToPointAssociation"><strong>Explore the docs »</strong></a>

[View Demo](https://github.com/ivsg-psu/FeatureExtraction_Association_PointToPointAssociation/tree/main/Documents) · [Report Bug](https://github.com/ivsg-psu/Featurdata given eExtraction_Association_PointToPointAssociation/issues) · [Request Feature](https://github.com/ivsg-psu/FeatureExtraction_Association_PointToPointAssociation/issues)

***

<!-- TABLE OF CONTENTS -->
<details open="open">
  <summary><h2 style="display: inline-block">Table of Contents</h2></summary>
  <ol>
    <li>
      <a href="#about-the-project">About the Project</a>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="structure">Repo Structure</a>
      <ul>
        <li><a href="#directories">Top-Level Directories</li>
        <li><a href="#dependencies">Dependencies</li>
      </ul>
    </li>
    <li><a href="#functions">Functions</li>
      <ul>
        <li><a href="#basic-support-functions">Basic Support Functions</li>
        <ul>
          <li><a href="#fcn_laps_plotlapsxy">fcn_Laps_plotLapsXY - Plotting utility for lap outputs</li>
        </ul>
        <li><a href="#core-functions">Core Functions</li>
        <ul>
          <li><a href="#fcn_laps_breakdataintolaps">fcn_Laps_breakDataIntoLaps - Core function of the repo, breaks data into laps</li>
        </ul>
      </ul>
    <li><a href="#usage">Usage</a></li>
     <ul>
     <li><a href="#general-usage">General Usage</li>
     <li><a href="#examples">Examples</li>
     <li><a href="#definition-of-endpoints">Definition of Endpoints</li>
     </ul>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
  </ol>
</details>

***

<!-- ABOUT THE PROJECT -->
## About The Project

<!--[![Product Name Screen Shot][product-screenshot]](https://example.com)-->

Typical Latitude Longitude Altitude data (LLA) from a vehicle omits altitude information. And even when that information is available, the altitude information for near-road features is generally missing. This repo supports the collection of DEM GeoTIFF files from online database sources with a focus on Pennsylvania data.

<a href="#fielddatacollection_roadsegments_demimport">Back to top</a>

***

<!-- GETTING STARTED -->
## Getting Started

To get a local copy up and running follow these simple steps.

### Installation

1. Make sure to run MATLAB 2020b or higher. Why? The "digitspattern" command used in the DebugTools utilities was released late 2020 and this is used heavily in the Debug routines. If debugging is shut off, then earlier MATLAB versions will likely work, and this has been tested back to 2018 releases.

2. Clone the repo

   ```sh
   git clone https://github.com/ivsg-psu/FieldDataCollection_RoadSegments_DEMImport
   ```

3. Run the main code in the root of the folder (script_demo_Laps.m), this will download the required utilities for this code, unzip the zip files into a Utilities folder (.\Utilities), and update the MATLAB path to include the Utility locations. This install process will only occur the first time. Note: to force the install to occur again, delete the Utilities directory and clear all global variables in MATLAB (type: "clear global *").
4. Confirm it works! Run script_demo_Laps. If the code works, the script should run without errors. This script produces numerous example images such as those in this README file.

<a href="#fielddatacollection_roadsegments_demimport">Back to top</a>

***

<!-- STRUCTURE OF THE REPO -->
### Directories

The following are the top level directories within the repository:
<ul>
 <li>/Documents folder: Descriptions of the functionality and usage of the various MATLAB functions and scripts in the repository.</li>
 <li>/Functions folder: The majority of the code for the point and patch association functionalities are implemented in this directory. All functions as well as test scripts are provided.</li>
 <li>/Utilities folder: Dependencies that are utilized but not implemented in this repository are placed in the Utilities directory. These can be single files but are most often folders containing other cloned repositories.</li>
</ul>

<a href="#fielddatacollection_roadsegments_demimport">Back to top</a>

***

### Dependencies

Dependencies are automatically installed by running the main demo script of the code. This must be run at least once before calling functions individually.

* [Errata_Tutorials_DebugTools](https://github.com/ivsg-psu/Errata_Tutorials_DebugTools) - The DebugTools repo is used for the initial automated folder setup, and for input checking and general debugging calls within subfunctions. The repo can be found at: <https://github.com/ivsg-psu/Errata_Tutorials_DebugTools>

* [PathPlanning_PathTools_PathClassLibrary](https://github.com/ivsg-psu/PathPlanning_PathTools_PathClassLibrary) - the PathClassLibrary contains tools used to find intersections of the data with particular line segments, which is used to find start/end/excursion locations in the functions. The repo can be found at: <https://github.com/ivsg-psu/PathPlanning_PathTools_PathClassLibrary>

    Each should be installed in a folder called "Utilities" under the root folder, namely ./Utilities/DebugTools/ , ./Utilities/PathClassLibrary/ . If you wish to put these codes in different directories, the main call stack in script_demo_(reponame) can be easily modified with strings specifying the different location, but the user will have to make these edits directly.

<a href="#fielddatacollection_roadsegments_demimport">Back to top</a>

***

<!-- FUNCTION DEFINITIONS -->
## Functions

### Basic Support Functions

#### fcn_Laps_plotLapsXY

The function fcn_Laps_plotLapsXY plots the laps. For example, the function was used to make the plot below of the last Sample laps.
<pre align="center">
  <img src=".\Images\fcn_Laps_plotLapsXY.png" alt="fcn_Laps_plotLapsXY picture" width="400" height="300">
  <figcaption>Fig.1 - The function fcn_Laps_plotLapsXY plots the lap outputs.</figcaption>
  <!--font size="-2">Photo by <a href="https://unsplash.com/ko/@samuelchenard?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Samuel Chenard</a> on <a href="https://unsplash.com/photos/Bdc8uzY9EPw?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></font -->
</pre>

<a href="#fielddatacollection_roadsegments_demimport">Back to top</a>

***

### Core Functions

#### fcn_DEMImport_ImportDEMsFromPAMAP

The function fcn_DEMImport_ImportDEMsFromPAMAP is a core function for this repo imports the PAMAP data for the state of Pennsylvania. This dataset is about 2 TB in size and takes several days to download. This function is designed to start / stop / restart correctly, even if interrupted. 

This specific data set was collected over 2006 to 2008 and is separated into North and South sections. The download process follows the exact folder structure - and hence data separation - as used by the PASDA service. 

<pre align="center">
  <img src=".\Images\fcn_DEMImport_ImportDEMsFromPAMAP.png" alt="fcn_DEMImport_ImportDEMsFromPAMAP picture" width="1705" height="966">
  <figcaption>The function fcn_DEMImport_ImportDEMsFromPAMAP imports all PAMAP data from the PASDA website.</figcaption>
  <!--font size="-2">Photo by <a href="https://unsplash.com/ko/@samuelchenard?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Samuel Chenard</a> on <a href="https://unsplash.com/photos/Bdc8uzY9EPw?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></font -->
</pre>

<a href="#fielddatacollection_roadsegments_demimport">Back to top</a>

***

<!-- USAGE EXAMPLES -->
## Usage
<!-- Use this space to show useful examples of how a project can be used.
Additional screenshots, code examples and demos work well in this space. You may
also link to more resources. -->

### General Usage

Each of the functions has an associated test script, using the convention

```sh
script_test_fcn_fcnname
```

where fcnname is the function name as listed above.

As well, each of the functions includes a well-documented header that explains inputs and outputs. These are supported by MATLAB's help style so that one can type:

```sh
help fcn_fcnname
```

for any function to view function details.

<a href="#fielddatacollection_roadsegments_demimport">Back to top</a>

***

### Examples

1. Run the main script to set up the workspace and demonstrate main outputs, including the figures included here:

   ```sh
   script_demo_Laps
   ```

    This exercises the main function of this code.

2. After running the main script to define the included directories for utility functions, one can then navigate to the Functions directory and run any of the functions or scripts there as well. All functions for this library are found in the Functions sub-folder, and each has an associated test script. Run any of the various test scripts; each can work as a stand-alone script.

<a href="#fielddatacollection_roadsegments_demimport">Back to top</a>

***

### Definition of Endpoints

The codeset uses two types of zone definitions:

1. A point location defined by the center and radius of the zone, and number of points that must be within this zone. An example of this would be "travel from home" or "to grandma's house". The point "zone" specification is given by an X,Y center location and a radius in the form of [X Y radius], as a 3x1 matrix. Whenever the path passes within the radius with a specified number of points within that radius, the minimum distance point then "triggers" the zone.

    <img src=".\Images\point_zone_definition.png" alt="point_zone_definition picture" width="200" height="200">

2. A line segment. An example is the start line or finish line of a race. A runner has not started or ended the race without crossing these lines. For line segment conditions, the inputs are condition formatted as: [X_start Y_start; X_end Y_end] wherein start denotes the starting coordinate of the line segment, end denotes the ending coordinate of the line segment. The direction of start/end lines of the segment are defined such that a correct crossing of the line is in the positive cross-product direction defined from the vector from start to end of the segment.

    <img src=".\Images\linesegment_zone_definition.png" alt="linesegment_zone_definition picture" width="200" height="200">

These two conditions can be mixed and matched, so that one could, for example, find every lap of data where someone went from a race start line (defined by a line segment) to a specific mountain peak defined by a point and radius.

The two zone types above can be used to define three types of conditions:

1. A start condition - where a lap starts. The lap does not end until and end condition is met.
2. An end condition - where a lap ends. The lap cannot end until this condition is met.
3. An excursion condition (optional) - a condition that must be met after the start point, and before the end point. The excursion condition must be met before the end point is counted.

Why is an excursion point needed? Consider an example: it is common for the start line of a marathon to be quite close to the start line, sometimes even just a few hundred feet after the start line. This setup is for the practical reason that runners do not want to make long walks to/from starting locations to finish location either before, and definitely not after, such a race. As a consequence, it is common that, immediately after the start of the race, a runner will cross the finish line before actually finishing the race. This happens in field data collection when one accidentally passes a start/end station, and then backs up the vehicle to reset. In using these data recordings, we would not want these small segment to count as a complete laps, for example the 100-ish meter distance to be counted as a marathon run. Rather, one would require that the recorded data enter some excursion zone far away from the starting line for such a "lap" to count. Thus, this laps code allows one to define an excursion point as a location far out into the course that one must "hit" before the finish line is counted as the actual "finish" of the lap.

* For each lap when there are repeats, the resulting laps of data include the lead-in and fade-out data, namely the datapoint immediately before the start condition was met, and the datapoint after the end condition is met. THIS CREATES REPLICATE DATA. However, this allows better merging of data for repeated laps, for example averaging data exactly from start to finish, or to more exactly calculate velocities on entry and exit of a lap by using windowed averages or filters.

* Points inside the lap can be set for the point-type zones. These occur as optional input arguments in fcn_Laps_findPointZoneStartStopAndMinimum and in the core definition of a point zone as the 2nd argument. For example, the following code:

  ```Matlab
  start_definition = [10 3 0 0]; % Radius 10, 3 points must pass near [0 0]
  ```

  requires 3 points to occur within the start zone area.

<a href="#fielddatacollection_roadsegments_demimport">Back to top</a>

***

<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE` for more information.

<a href="#fielddatacollection_roadsegments_demimport">Back to top</a>

***

## Major release versions

This code is still in development (alpha testing)

<a href="#fielddatacollection_roadsegments_demimport">Back to top</a>

***

<!-- CONTACT -->
## Contact

Sean Brennan - [sbrennan@psu.edu](sbrennan@psu.edu)

Project Link: [hhttps://github.com/ivsg-psu/FieldDataCollection_RoadSegments_DEMImport](https://github.com/ivsg-psu/FieldDataCollection_RoadSegments_DEMImport)

<a href="#fielddatacollection_roadsegments_demimport">Back to top</a>

***

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
