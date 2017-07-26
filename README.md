#  SCOUT Mobile (iOS) 

## Synopsis

Contains the projects files for the iOS version of SCOUT Mobile

SCOUT Mobile is a derivative if NICS Mobile, hence the interchangeability of the names.

##Dependencies

###iOS

The Google Maps framework has been removed from the iOS project files.
This framework is required for proper compilation / app functionality.

To acquire the Google Maps framework for the app, download the framework from the following URL:

https://developers.google.com/maps/documentation/ios-sdk/start

After downloading the framework, copy the file "GoogleMaps.framework" to the directory: "nics-mobile/ios/Pods/GoogleMaps/Frameworks/"


## Configuration

Configuration files have been removed from the "ios" project directory, and moved to the "config file templates" directory.
All configuration files have had the ".template" file extension appended to their file names.

Steps required to resolve configuration files to get the projects in working order:
<lu>
<li>1. Go into each template file and populate the template information</li>
<li>2. Remove the ".template" extension from each template file</li>
<li>3. Drag and drop the "config file templates/ios" folder onto the root "ios" folder</li>
  <ul>
    <li>This should merge the folders and add the modified template files into the project directories, restoring the projects to working order.</li>
    </ul>
</ul>



###iOS

NICS Mobile uses Cocoa Pods which requires you to open it using the "NICS Mobile.xcworkspace" file instead of the typical ".xcodeproj" file.

The configuration file can be found at this path: nics_mobile/ios/NICS Mobile/Localized/Settings.bundle/Root.plist

The bottom half of the file is what needs to be configured. Starting at the "Select NICS Server" field. The fields get configured with the same info that is used in the Android config.

Your Google Maps API key needs to be entered in the AppDelegate.m file at this path nics_mobile/ios/NICS Mobile/AppDelegate.m)
