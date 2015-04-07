The system is based on the well known client/server
architecture. Clients are Web browsers and the server is HTTP
streaming server, such as Icecast (http://www.icecast.org). Notice
that in this configuration, the server has to send many copies of the
stream as requests.

The encoding is performed one time in the server side, using for
example, FFMPEG (http://ffmpeg.org). The streamed sequence has only
visual information (without audio) and the encoder+container is
Theora+OGG (http://www.theora.org).

The communication between the programs (oggfwd included) is based on
the stdout and stdin Unix pipes, avoiding to generate temporal
files.

Example:
<pre>
...............................................................<br>
....Client side...................................+---------+..<br>
..................................................|         |..<br>
..................................................| Firefox |..<br>
..................................................|         |..<br>
..................................................+---------+..<br>
.......................................................^.......<br>
| OGG<br>
.......................................................|.......<br>
....Server side........................................|.......<br>
.......................................................|.......<br>
.+------------+.....+--------+.....+--------+.....+----+----+..<br>
.|    ESA     |.RAW.|        |.OGG.|        |.OGG.|         |..<br>
.|   image    +---->| FFMPEG +---->| oggfwd |---->| Icecast |..<br>
.| repository |.... |        |.....|        |.....|         |..<br>
.+------------+.... +--------+.....+--------+.....+----+----+..<br>
.......................................................|.......<br>
| OGG<br>
.......................................................v.......<br>
....Client side...................................+---------+..<br>
..................................................|         |..<br>
..................................................| Firefox |..<br>
..................................................|         |..<br>
..................................................+---------+..<br>
...............................................................<br>
</pre>