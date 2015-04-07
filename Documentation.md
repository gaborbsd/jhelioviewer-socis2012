The system is composed of some open source software that are described in SoftwareRequirements and some shell scripts built around them. One design principle was reconfigurability. Taking into account this requirement and the fact that HTML5 pages need to be generated to display the streamed videos, using an XML configuration file and XSLT stylesheets that generate the necessary artifacts seemed to be a practical choice.

The streaming part follows the producer - consumer pattern since the last video fragment should be emitted regardless of the delay of the video generation in producer. It is implemented in such a way that the producer starts to generate video files named as <tt>ChannelName,x.ogg</tt>, where <tt>x</tt> is a constrantly increasing number and this script only keeps the last few videos.  In turn, the consumer script always takes the last one of these videos and emits it entirely. After one cycle it picks again the last video and sends it the streaming server. The synchronization between the consumer and the producer is kept simple; the producer does not immediately delete the last video so the consumer has time to finish emitting the current video and pick up the latest one.

The <tt>conf/</tt> directory contains the XML configuration file <tt>conf.xml</tt> and the corresponding DTD <tt>conf.dtd</tt> to validate it. The validation can be executed with <tt>make validate</tt> in the top-level directory.

The <tt>bin/</tt> directory contains the producer and consumer scripts, which are configured by command-line arguments and a simple PHP script that adds color palettes to the grayscale images. This code snippet has been taken from the helioviewer.org code to reproduce exactly the same behaviour.

The <tt>xsl/</tt> directory contains several XSLT stylesheets:
  * To generate an <tt>index.html</tt> page that lists all the available channels.
  * To generate per-channel pages that display the video.
  * To generate a startup.sh script that can easily start/stop/checks the specified channel or all channels at a time.
  * To generate a JNLP file that is referenced by the per-channel pages and will be able to start the full JHelioViewer application.
And a <tt>lookup.xml</tt> file that defines lookup paths for image directories and color tables.

The <tt>data/</tt> directory contains a CSS and a JavaScript file for the HTML pages. This latter implements the easy navigation to subchannels. Clicks on the video area are detected and if the channel has subpages the corresponding tile will be loaded.

The <tt>img/</tt> directory only contains splash images that are used on the html video area while the video is loading.

The top-level <tt>Makefile</tt> defines the following targets:
  * validate: Validates the configuration file.
  * build-script: Creates a <tt>script</tt> directory with all necessary artifacts for streaming.
  * build-www: Creates a <tt>www</tt> directory with all the HTML pages and accompanying files. Only the JHelioviewer.jar file needs to be copied here manually.
  * clean: Cleans up the <tt>script</tt> and <tt>www</tt> directories.

Once the scripts are generated, the <tt>startup.sh</tt> script can be used in two ways:
  * <tt>startup.sh [start|stop|check]</tt>: Starts, stops or checks all the channels. Check means verifying whether the channel is running and restarting it in case it stopped.
  * <tt>startup.sh channame [start|stop|check]</tt>: Start, stops or checks the channel specified with channame.

InstallationInstructions contains a step-by-step guide to install the system.