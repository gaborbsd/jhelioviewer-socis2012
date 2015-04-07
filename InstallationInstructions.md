# Installation Instructions #

<ol>
<li>Verify SoftwareRequirements and install all dependencies.</li>

<li>Verify that <tt>ffmpeg</tt> is installed with libtheora support built in. You can check this in the output of <tt>ffmpeg -version</tt>. If this is not the case, consult the documentation of your OS distribution to find out how to install ffmpeg with libtheora support.</li>

<li>Now configure Icecast. The default settings are probably fine but you should change the default password and remember your choice for the configuration of streaming that will follow.</li>

<li>Start the Icecast server. You distribution's packaging system probably created a run control script somewhere in <tt>/etc/init.d</tt> or <tt>/etc/rc.d</tt>. Executing this with the <tt>start</tt> argument should do.</li>

<li>Check out the system from the repository:<br>
<br>
<tt>svn checkout <a href='http://jhelioviewer-socis2012.googlecode.com/svn/trunk/'>http://jhelioviewer-socis2012.googlecode.com/svn/trunk/</a> jhelioviewer-channels</tt></li>

<li>Edit <tt>jhelioviewer-channels/conf/conf.xml</tt> to match your environment and the desired channel setup. You have an example file in <tt>jhelioviewer-channels/conf/conf.example.xml</tt>, which documents the configuration format.</li>

<li>Change to the <tt>jhelioviewer-channels</tt> directory and validate your configuration file to ensure it is syntactically correct:<br>
<blockquote><tt>cd jhelioviewer-channels</tt><br />
<tt>make validate</tt></li></blockquote>

<li>Build scripts. The resulting scripts will appear in the <tt>script</tt> subdirectory.<br>
<blockquote><tt>make build-script</tt></li></blockquote>

<li>Build the webpages. They will appear in the www directory.<br>
<blockquote><tt>make build-www</tt></li></blockquote>

<li>Configure the web server to serve the web pages you just built.</li>

<li>In the script directory, run<br>
<blockquote><tt>nohup ./startup.sh start & </tt>
to start the system. Basically, this script can be called in two ways. The first syntax is <tt>startup.sh [start|stop|check]</tt>, which starts or stops all channels or verifies if they are running and in case something has stopped, it will restart the components. The second syntax is <tt>startup.sh channel [start|stop|check]</tt>, which does the same but only for the specified channel.</li></blockquote>

<li>You can configure cron to periodically run<br>
<blockquote><tt>startup.sh check</tt>
to check whether the channels are still running.</li>
</ol>