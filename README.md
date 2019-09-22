# bootstrapinstallr<br/>
Bash script to install packages and apps in DMGs on a fresh Mac. <br/><br/>
Run with:<br/>
`curl https://raw.githubusercontent.com/MacsInSpace/bootstrapinstallr/master/install.sh | bash -s  http://Link.To.Install.local/list.txt`
<br/><br/>
The second argument is a list of DMGs or PKGs that you want on the 'image'<br/>
<br/><br/>

Supports DMGs containing Apps/pkgs and mpkgs or stand alone pkg link lists.<br/>
<br/><br/>
Added a function to search a page for a link... (milage may vary on this one. You've been warned..)<br/><br/>
example usage:<br/><br/>

`curl https://raw.githubusercontent.com/MacsInSpace/bootstrapinstallr/master/install.sh | bash -s  https://raw.githubusercontent.com/MacsInSpace/bootstrapinstallr/master/list.txt`
 or add the link list to the script on line ~20 

