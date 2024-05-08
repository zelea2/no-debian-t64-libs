# no-debian-t64-libs

Unix date was historically encoded as a 32bit integer (representing seconds from year 1970) and it will overflow sometime in 2038
Debian started on February 2024 (14 years ahead?) to rename all libraries which have the unix time encoded as a 64bit integer by 
adding the t64 suffix. This forces all programs using unix time (thousands of them) to link to these new libraries and make sure 
the time variables use 64bit for all 64bit architectures. In a few years time when the conversion is considered finished all the
libraries will be renamed again without the t64 suffix. 

This is all fine and dandy but it is creating major headaches for held packages, depreciated packages (which you still want to run) 
or binary only programs which all need to be recompiled. I've already spent so much time hopping arround this issue that I've
got fed up and decided to skip this "t64" transition period even if this means some programs might get the time wrong
(hasn't happened so far).

To automate this process I've used the script running hooks provided by the APT package and added the following files:
 - /etc/apt/apt.conf.d/90-no-t64     # the hooks
 - /etc/apt/strip-t64-lists.pl       # Perl script to strip the updated lists from the t64 suffix
 - /etc/apt/no-t64-libs.pl           # Perl to repack the downloaded .deb files with no dependencies to 'lib*t64' libraries

If you already have some t64 libs installed on your system then you will ALSO have to manually rename all files with
the t64 suffix in <b>/var/lib/dpkg/info/</b> and then edit the <b>/var/lib/dpkg/status</b> and remove the suffixes from there too.
This step is only needed once if your system already has some t64 libraries installed.
