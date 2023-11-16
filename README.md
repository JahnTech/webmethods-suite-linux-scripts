# Linux Scripts for the webMethods Suite

This is a collection of scripts for the webMethods Suite on Linux.
They cover the following areas:

- Installation
- Development
- Operations


## Installation

The scripted installation of the webMethods is not that difficult.
But it can take some effort to figure out the exact steps and syntax.

The scripts in this area are intended to serve as a starting point to speed
things up. Therefore they do not aim to cover every possible combination.

## Development

Yet to come.

## Operations

You can do the following things with components of the webMethods suite
(not all components allow all operations).

- Start (asynchronous, returns immediately)
- Stop (synchronous, waits for end of shutdown)
- Restart (stop + start)
- Kill
- Get process ID (PID)
- Check on status (OS-level process running, no functional check)
- View log files
- Get log file names

In addition the script provides a self-install mechanism that creates
a config file, symbolic links etc. in $WM_ROOT/bin and /etc/init.d
(if installed by root).

### Documentation

The documentation is included in the scripts themselves, so that
you always have it available.

Please check the documentation in the script for your version,
whether or not a particular component has been tested with this
version. Since this is a community project, there may be
components where this not been done yet.

### Versions

The initial version of this script was created in 2009 and has since
been updated for newer versions of the webMethods Suite.
The decision to keep individual scripts for the various versions
was made to easily handle the sometimes subtle differences
(e.g. changes to paths) between versions. Also, it makes it
easier to add new components (like the Microservices Runtime).



______________________
These tools are provided as-is and without warranty or support. They do not constitute part of the Software AG product suite. Users are free to use, fork and modify them, subject to the license agreement. While Software AG welcomes contributions, we cannot guarantee to include every contribution in the master project.

Contact us at [TECHcommunity](mailto:technologycommunity@softwareag.com?subject=Github/SoftwareAG) if you have any questions.
