# bootstrapinstallr<br/>
Bash script to install packages and apps in DMGs on a fresh Mac. <br/><br/>
Run with:<br/>
`curl https://raw.githubusercontent.com/MacsInSpace/bootstrapinstallr/master/install.sh | bash -s  http://Link.To.Install.local/list.txt`
<br/><br/>
The second argument is a list of DMGs or PKGs that you want on the 'image'<br/>
Unfortunately doing the old  `bash <( curl https://raw.githubusercontent.com/MacsInSpace/bootstrapinstallr/master/install.sh ) http://Link.To.Install.local/list.txt` fails to pass the arguement. <br/>Any ideas?
<br/><br/>

Supports DMGs containing Apps/pkgs and mpkgs or stand alone pkg link lists.
