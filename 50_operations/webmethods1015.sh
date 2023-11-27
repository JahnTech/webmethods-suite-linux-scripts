#!/bin/bash

# chkconfig: 2345 83 03
# description: Starts and stops components of the webMethods suite


# (c) Copyright 2023 Software AG, Darmstadt, Germany and/or Software AG USA  Inc.,
# Reston, United States of America, and/or their suppliers.
# http://www.softwareag.com

#  SPDX-License-Identifier: Apache-2.0
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.



# NAME
#     webmethods1015.sh - Manages operations of webMethods components
#
#
# SYNOPSIS
#
#     webmethods1015.sh [OPTIONS] COMMAND COMPONENT    or   wm_COMPONENT [OPTIONS] COMMAND
#
#
#        OPTIONS     -f             = force
#                    -v             = verbose output
#                    -c configFile  = provide custom config file (instead of /etc/webmethods1015.cfg)
#                    -u USER        = provide custom user (instead of sag)
#                    -g GROUP       = provide custom group (instead of sag)
#
#        COMMAND     start       = start (asynchronous)
#                    stop        = stop (synchronous)
#                    kill        = hard kill
#                    restart     = stop+start
#                    pid         = return PID
#                    status      = display status (OS process only)
#                    log         = display error/warning log file
#                    logfull     = display detailed log file
#                    logfile     = return name of error/warning log file
#                    logfilefull = return name of detailed log file
#
#
#       COMPONENT    is      = Integration Server
#                    msr     = Microservice Runtime
#                    mws     = My webMethods Server
#                    um      = Universal Messaging
#                    brk     = Broker
#
#                The following components have so far not been tested with this
#                version of the script. Please do so carefully before using them.
#
#                    ae      = Analytic Engine
#                    wsdc    = Web Service Data Collector
#                    idc     = Infrastructure Data Collector
#                    ino     = CentraSite database
#                    ctp     = Common Runtime
#                    smh     = System Management Hub
#                    tsa     = Terracotta Server Array
#                    od      = OneData
#                    spm     = Platform manager
#                    cce     = Command Central
#                    mz      = Mashzone
#                    mzcl    = Mashzone Cloud Agent
#
#
#     ./webmethods1015.sh install PATH_TO_WEBMETHODS
#     ./webmethods1015.sh install_symlinks PATH_TO_WEBMETHODS
#     ./webmethods1015.sh install_aliases PATH_TO_WEBMETHODS
#     ./webmethods1015.sh uninstall_symlinks PATH_TO_WEBMETHODS
#     ./webmethods1015.sh uninstall_aliases
#
#
# ALIASES
#     The following aliases are created:
#
#       wm          -> $WM_ROOT/bin/webmethods1015.sh
#       wmis        -> $WM_ROOT/bin/wm_is
#       wmmsr       -> $WM_ROOT/bin/wm_msr
#       wmbrk       -> $WM_ROOT/bin/wm_brk
#       wmmws       -> $WM_ROOT/bin/wm_mws
#       wmae        -> $WM_ROOT/bin/wm_ae
#       wmwsdc      -> $WM_ROOT/bin/wm_wsdc
#       wmidc       -> $WM_ROOT/bin/wm_idc
#       wmino       -> $WM_ROOT/bin/wm_ino
#       wmctp       -> $WM_ROOT/bin/wm_ctp
#       wmsmh       -> $WM_ROOT/bin/wm_smh
#       tsa         -> $WM_ROOT/bin/wm_tsa
#       od          -> $WM_ROOT/bin/wm_od
#       um          -> $WM_ROOT/bin/wm_um
#       spm         -> $WM_ROOT/bin/wm_spm
#       cce         -> $WM_ROOT/bin/wm_cce
#       mzcl        -> $WM_ROOT/bin/wm_mzcl
#       mz          -> $WM_ROOT/bin/wm_mz
#
#     When invoked via an alias (or the symlink it points to) the respective
#     component is automatically determined and does not need to be provided
#     as a separate parameter any more. This is purely for convenience purposes.
#
#     If the installation was performed as root, the aliases will be stored in
#     
#            /etc/profile.d/webmethods1015.sh
#
#     Otherwise they are in the user's aliases in ~/.bashrc
#
# DESCRIPTION
#     You can do the following things with components of the webMethods suite
#     - Start (asynchronous, returns immediately)
#     - Stop (synchronous, waits for end of shutdown)
#     - Check on status (OS-level process running, no functional check)
#
#     In addition the script provides a self-install mechanism that creates
#     a config file, symbolic links etc. in $WM_ROOT/bin and /etc/init.d
#     (if installed by root). For details see section 'INSTALLATION'.
#
#     The script installs a number of symlinks pointing to itself. Those are
#     shortcuts for running it. So instead of running "webmethods1015.sh start is"
#     it is also possible to call "wm_is start". These symlinks are created
#     as part of the installation.
#
#     For Integration Server, if a LOCKFILE is found without a corresponding
#     program instances running, the LOCKFILE is removed and Integration
#     Server started. A warning will be issued.
#
#
# INSTALLATION
#     The scripts must be installed before its first usage. It is important
#     that for this to work it must be started from its current location with the
#     following command:
#
#         ./webmethods1015.sh [-f] install PATH_TO_WEBMETHODS
#
#     It then
#      - creates a 'bin' directory in $WM_ROOT,
#      - if invoked with the "-f" flag (force), delete a script backup if one exists,
#      - create backup if an older version of the script is found,
#      - copies itself there,
#      - creates a config file in
#         - /etc/webmethods1015.cfg , if installed by root
#         - ~/.webmethods1015 , otherwise
#      - creates shortcut symlinks pointing to itself for the various webMethods
#        components (all in $WM_ROOT). 
#
#     If the installation is performed by root, those symlinks are also created in 
#     /etc/init.d so that an automated startup can easily be set up (this is not
#      done automatically).
#
#     For mashzone,as a first step, the cloud agent needs to be registered as a 
#     start up service (using ./CloudAgentApp.sh install command available in 
#     mashzone installation). For all other components use 'chkconfig'. 
#     Please see the man page for 'chkconfig' for details on this.





# You are not allowed to install or use the Product without a
# corresponding license agreement.
#
# If you have entered into a commercial license agreement with one of
# Software AG's subsidiaries or distributors ("Commercial License
# Agreement") the installation and use of the Product is subject to your
# acceptance of additional terms which are provided for you in "Part B:
# Additional Terms".
#
# If you have not entered into a Commercial License Agreement you must
# execute the license agreement with Software AG which is provided for you
# in "Part C: Software AG Evaluation License Agreement for Trial Versions
# of Software AG Products" ONLY.
#
# COPYRIGHT AND TRADEMARK NOTICE
#
# The name Software AG, webMethods and all Software AG product names are
# either trademarks or registered trademarks of Software AG and/or
# Software AG USA, Inc. Other company and product names mentioned herein
# may be trademarks of their respective owners.
#
# Other brands or names mentioned may be trademarks or registered
# trademarks of their respective owners.
#
# Software AG or its subsidiaries are the sole owner of all intellectual
# property rights to the Products and accompanying user documentation or
# have the respective distribution rights. References made in or on the
# Products to the copyright and/or to the industrial property rights must
# not be altered, deleted or obliterated in any manner.
#
# No right, title or interest in any trademark or trade names of Software
# AG or its subsidiaries is granted hereunder.




# Sanitize program name, in case it was called during startup/shutdown
# of the system (where Sxx or Kxx preceed the actual name)
PRG=`basename $0 | sed 's/^[KS][0-9][0-9]//'`



# Base part of name, should indicate version of webMethods
NAME_MAIN=webmethods1015

# Config file for installation by root
WM_CFG_ROOT=/etc/$NAME_MAIN.cfg

# Config file for installation by non-provileged user
WM_CFG_NONROOT=~/.$NAME_MAIN

# Aliases file for installation by root
PROFILE_DIR_ROOT=/etc/profile.d
PROFILE_WM_ROOT=$PROFILE_DIR_ROOT/$NAME_MAIN.sh


# Aliases file for installation by non-root
PROFILE_DIR_NONROOT=~
PROFILE_WM_NONROOT=$PROFILE_DIR_NONROOT/.bashrc



PRG_NAME=$NAME_MAIN.sh
WM_FILE_ACCESSS_CFG=640
WM_FILE_ACCESSS_BIN=750

# Default user for running webMethods components
WM_USER=sag

# Default group for running webMethods components
WM_GROUP=$WM_USER


# Control "chattiness" of output to STDOUT
OUTPUT_VERBOSE=0



# Handle output of messages.
#
# Usage:   output { err | info | debug } MESSAGE
# 
# Level:  err     Send to STDERR
#         info    Send to STDOUT
#         debug   Send to STDOUT if $OUTPUT_VERBOSE=1
#
function output
{
    PRIO=$1
    MSG="$2"
    if [ "$PRIO" = "info" ]; then
		echo "$PRG: $MSG"
    elif [ "$PRIO" = "err" ]; then
		echo "$PRG: $MSG" >&2
    elif [ "$PRIO" = "debug" -a "$OUTPUT_VERBOSE" -eq 1 ]; then
		echo "$PRG: $MSG"
    fi
}



# Output message with return code and exit
#
# Usage:   abort RC
#
function abort
{
    RC="$1"
    if [ "$OUTPUT_VERBOSE" -eq 1 ]; then
		output err "Aborting ... (RC=$RC)"
    fi
    exit $RC
}


# Appends a line to a textfile, provided the line or a search
# is not already in that file
#
# Usage:   file_append_line FILE LINE [ PATTERN ]
#
# No backup is created, you need to do that manually
# The reason for that approach is that in many cases
# several append operations will happen to one file
# in one "logical" operation. And you certainly don't
# want to have a backup for each of those appends, right?

function file_append_line
{
    FILE="$1"
    LINE="$2"
    PATTERN="$3"

    if [ -z $PATTERN ]; then
		PATTERN="$LINE"
    fi

    # Does file exist?
    if [ ! -e $FILE ]; then
		output err "File '$FILE' does not exist"
		abort 1
    fi

    # Perform search
    FOUND=`grep "$PATTERN" $FILE >/dev/null 2>&1;echo $?`

    # Check whether pattern was found and append as appropriate
    if [ $FOUND -ne 0 ]; then
		output debug "File '$FILE' does not contain '$PATTERN', will append line"

		# Is file writable?
		if [ ! -w "$FILE" ]; then
			output err "File '$FILE' is not writable to current user (`whoami`)"
			abort 1
		fi

		echo "$LINE" >> $FILE
		RET=$?
		if [ $RET -ne 0 ]; then
			output err "Error while trying to append '$LINE' to file '$FILE'"
			abort 1
		fi
    else
		output debug "File '$FILE' already contains '$PATTERN', will do nothing"
    fi
}


# ===================================================
#  Check whether key exists in config file 
#  If not, create it with provided default value
# ===================================================
function cfg_check_value() {
    FILE_TO_CHECK="$1"
    KEY="$2"
    VALUE="$3"
    KEY_RC=`grep -e ^$KEY $FILE_TO_CHECK > /dev/null; echo $?`
    if [ $KEY_RC -ne 0 ]; then
		echo "$KEY=$VALUE" >> $FILE_TO_CHECK
		echo "Added '$KEY=$VALUE' to $FILE_TO_CHECK"
    fi
}


# ===================================================
#  Check whether config file is present
#  and has the right access rights
# ===================================================
function read_cfg() {

    CFG_FILE="$1"
    if [ -e "$CFG_FILE" ]; then
 
        # Check file access rights
		WM_CFG_ACCESS_CURRENT=`stat --format=%a $CFG_FILE`
		if [ $WM_CFG_ACCESS_CURRENT -ne $WM_FILE_ACCESSS_CFG ]; then
			echo "Config file '$CFG_FILE' has wrong access rights. Current is '$WM_CFG_ACCESS_CURRENT', but must be '$WM_FILE_ACCESSS_CFG'. Trying to correct this ..." >&2

				# Set access rights
			chmod $WM_FILE_ACCESSS_CFG "$CFG_FILE"
			RET=$?
			if [ $RET -ne 0 ]; then
				echo "Error while trying to set access rights of '$CFG_FILE' to $WM_FILE_ACCESSS_CFG" >&2
				exit 1
			fi

			# Re-check for correct access rights
			WM_CFG_ACCESS_CURRENT=`stat --format=%a $CFG_FILE`
			if [ $WM_CFG_ACCESS_CURRENT -ne $WM_FILE_ACCESSS_CFG ]; then
				echo "Config file '$CFG_FILE' still has wrong access rights. Current is '$WM_CFG_ACCESS_CURRENT', but must be '$WM_FILE_ACCESSS_CFG'." >&2
				exit 1
			else
				echo "Successfully updated access rights of '$CFG_FILE'"
			fi
		fi
    else
		echo "Config file '$CFG_FILE' is missing. Have you initialized things by running './$PRG_NAME install PATH_TO_WEBMETHODS' ?" >&2
		exit 1
    fi

    # Fall back to default values if nothing is set in config file
    cfg_check_value "$CFG_FILE" "WM_ROOT" "/opt/softwareag"
    cfg_check_value "$CFG_FILE" WM_USER sag
    cfg_check_value "$CFG_FILE" WM_GROUP sag
    cfg_check_value "$CFG_FILE" SHUTDOWN_MAX_WAIT_RETRIES 20
    cfg_check_value "$CFG_FILE" SHUTDOWN_WAIT_INTERVAL 5
    cfg_check_value "$CFG_FILE" IGNORE_START \"\"
    cfg_check_value "$CFG_FILE" IGNORE_STOP \"\"
    cfg_check_value "$CFG_FILE" LOG_VIEWER less


    # Get required file owner
    REQUIRED_FILE_OWNER=`cat "$CFG_FILE" | grep "WM_USER" | awk -F = '{print $2}'`
    if [ -z $REQUIRED_FILE_OWNER ]; then
		# Fall back to WM_USER defined in this script
		REQUIRED_FILE_OWNER=$WM_USER
    fi

    # Check file owner
    WM_CFG_OWNER=`stat --format=%U "$CFG_FILE"`
    if [ "$WM_CFG_OWNER" != "$REQUIRED_FILE_OWNER" ]; then
		echo "Config file '$CFG_FILE' has wrong owner. Current is '$WM_CFG_OWNER', but must be '$REQUIRED_FILE_OWNER'" >&2
		exit 1
    fi

    # Source in the config file
    . "$CFG_FILE"
}




function create_backup() {
    ORIG_FILE="$1"
    BAK_FILE="$ORIG_FILE.bak"
	if [ -e "$BAK_FILE" ]; then
	    if [ $FLAG_FORCE -ne 1 ]; then
			echo -n "There already exists a file $ORIG_FILE and also a backup of it ($BAK_FILE). " >&2
			echo -n "This script will now terminate so that you can either rescue those data or delete them. " >&2
			echo "At least the backup ($BAK_FILE) must be deleted before the installation can proceed." >&2
			exit 1
	    else
			rm -f "$BAK_FILE"
			RET=$?
			if [ $RET -eq 0 ]; then
				echo "The old backup file '$BAK_FILE' was deleted since the force flag ('-f') was provided"
			else
				echo "Backup file '$BAK_FILE' could not be deleted" >&2
				exit 1
			fi
	    fi
	fi
    echo "There already exists a file $ORIG_FILE, it will be renamed to $BAK_FILE."
	mv "$ORIG_FILE" "$BAK_FILE"
	RET=$?
	if [ $RET -ne 0 ]; then
	    echo "An error occured while trying to rename $ORIG_FILE to $BAK_FILE." >&2
	    exit 1
	fi
}


# ===================================================
#  Get WM_ROOT from command line and check it
# ===================================================
function check_wmroot() {

   # Get wM root dir
    if [ ! -z "$1" ]; then
		if [ ! -z "$WM_ROOT" ]; then
			echo "Overriding WM_ROOT from config file with '$WM_ROOT', please check configuration for consistency"
		fi
		WM_ROOT="$1"
    fi

    # Check cmdline params
    if [ -z $WM_ROOT ]; then
		echo "You must provide the installation directory of webMethods as parameter" >&2
		exit 1
    fi

    # Remove trailing "/"
    WM_ROOT=`echo "$WM_ROOT" | sed 's/\/$//'`

    # Does the directory exist?
    if [ ! -d "$WM_ROOT" ]; then
		echo "The directory '$WM_ROOT' does not exist" >&2
		exit 1
    fi

}






# ===================================================
#  Install aliases (system-wide or for user only)
# ===================================================
function install_aliases() {

    
    check_wmroot "$1"

    # -----------------------
    # Create entry in /etc/profile.d or ~/.bashrc
    # (already determined by () )
    # -----------------------
    if [ -d "$PROFILE_DIR"  ]; then

		# If file to contain aliases does not exist yet, create as empty
		if [ ! -e $PROFILE_WM ]; then
			touch $PROFILE_WM
			RET=$?
			if [ $RET -ne 0 ]; then
				echo "Error while trying to create file $PROFILE_WM" >&2
				exit 1
			fi
		fi
		
		# Add aliases
		file_append_line $PROFILE_WM "alias wm=$WM_ROOT/bin/$PRG_NAME"
		index=0
		for i in ${WM_COMP[@]}
		do
			file_append_line $PROFILE_WM "alias wm${WM_COMP[$index]}=$WM_ROOT/bin/wm_${WM_COMP[$index]}"
			(( index = index + 1 ))
		done

		# Set file access rights
		chmod 755 $PROFILE_WM
		RET=$?
		if [ $RET -ne 0 ]; then
			echo "Error while trying to set file rights on $PROFILE_WM" >&2
			exit 1
		fi
    else
		echo "Target directory '$PROFILE_DIR' does not exist" >&2
		exit 1
    fi
}


# ===================================================
#  Remove aliases
# ===================================================
function uninstall_aliases() {

    if [ ! -e $PROFILE_WM ]; then
		output err "File '$PROFILE_WM', which contains the aliases, does not exist"
		abort 1
    elif [ ! -w $PROFILE_WM ]; then
		output err "File '$PROFILE_WM', which contains the aliases, is not writable to current user"
		abort 1
    else

		PROFILE_WM_BAK=$PROFILE_WM.bak

		# Delete old backup if it exists
		if [ -e $PROFILE_WM_BAK ]; then
			output debug "Found old backup file of aliases, will be deleted"
			rm $PROFILE_WM_BAK
			RET=$?
			if [ $RET -ne 0 ]; then
			output err "Error while trying to delete file $PROFILE_WM_BAK"
			abort 1
			fi
		fi

		# Create backup of alias file
		cp $PROFILE_WM $PROFILE_WM_BAK
		RET=$?
		if [ $RET -ne 0 ]; then
			output err "Error while trying to create backup file $PROFILE_WM_BAK"
			abort 1
		fi

		
			# Remove aliases
			cat $PROFILE_WM | grep -v "alias wm=$WM_ROOT/bin/$PRG_NAME" > $PROFILE_WM.tmp && mv $PROFILE_WM.tmp $PROFILE_WM
		index=0
		for i in ${WM_COMP[@]}
		do
			cat $PROFILE_WM | grep -v "alias wm${WM_COMP[$index]}=$WM_ROOT/bin/wm_${WM_COMP[$index]}" > $PROFILE_WM.tmp && mv $PROFILE_WM.tmp $PROFILE_WM
			(( index = index + 1 ))
		done
    fi
}


# ===================================================
#  Install symlinks for $PRG_NAME
# ===================================================
function create_component_symlinks() {
    LINK_DIR="$1"
    LINK_TARGET="$WM_ROOT/bin/$PRG_NAME"

    echo "Setting up symlinks in $LINK_DIR"
    index=0
    for i in ${WM_COMP[@]}
    do
		LINK="$LINK_DIR/wm_${WM_COMP[$index]}"
		if [ ! -e $LINK ]; then
			echo "  $LINK -> $LINK_TARGET"
			ln -s "$LINK_TARGET" "$LINK"
			RET=$?
			if [ $RET -ne 0 ]; then
				echo "Error while trying to create symlink $LINK -> $LINK_TARGET" >&2
				exit 1
			fi
		else
			echo "  File '$LINK' exists, no link created under this name"
		fi

		# Set access rights
		chmod 755 "$LINK"
		RET=$?
		if [ $RET -ne 0 ]; then
			echo "Error while trying to set access rights for $LINK" >&2
			exit 1
		fi
		(( index = index + 1 ))
    done
}


function install_symlinks() {
    check_wmroot "$1"

    # Create symlinks in webMethods' ./bin
    create_component_symlinks "$1/bin"

    # If run by root, also create symlinks in /etc/init.d
    if [ `whoami` == "root" ]; then
		create_component_symlinks /etc/init.d
    fi
}





# ===================================================
#  Remove symlinks for $PRG_NAME
# ===================================================
function delete_component_symlinks() {

    # Get param and remove trailing '/'
    SYMLINK_DIR=`echo "$1" | sed 's/\/$//'`

    index=0
    for i in ${WM_COMP[@]}
    do
		LINK_TARGET="$SYMLINK_DIR/wm_${WM_COMP[$index]}"
		# Does file exist?
		if [ -L "$LINK_TARGET" ]; then
			rm -f "$LINK_TARGET"
			RET=$?
			if [ $RET -ne 0 ]; then
				echo "Error while trying to remove symlink $LINK_TARGET" >&2
				exit 1
			fi
		else
			echo "Link '$LINK_TARGET' does not exist" >&2
		fi
		(( index = index + 1 ))
    done
}


function uninstall_symlinks() {
    check_wmroot "$1"

    # Delete symlinks in webMethods' ./bin
    delete_component_symlinks "$1/bin"

    # If run by root, also delete symlinks in /etc/init.d
    if [ `whoami` == "root" ]; then
		delete_component_symlinks /etc/init.d
    fi
}



# ===================================================
#  Install this file on a webMethods system
# ===================================================
function install() {

    check_wmroot "$1"

    # -----------------------
    # Copy self to $WM_ROOT/bin
    # -----------------------
    TARGET_DIR="$WM_ROOT/bin"
    if [ ! -d "$TARGET_DIR" ]; then
		echo "Creating directory $TARGET_DIR ..."
		mkdir -p "$TARGET_DIR"
		RET=$?
		if [ $RET -ne 0 ]; then
			echo "Error while trying to create directory '$TARGET_DIR'" >&2
			exit 1
		fi
	fi

	PWD=`pwd`
	if [ "$PWD" != "$TARGET_DIR" ]; then
		COPY_TARGET="$TARGET_DIR/$PRG_NAME"
		if [ -f "$COPY_TARGET" ]; then
			create_backup $COPY_TARGET
		fi
		
		cp "$0" "$COPY_TARGET"
		RET=$?
		if [ $RET -ne 0 ]; then
			echo "Error while trying to copy '$0' to '$COPY_TARGET'" >&2
			exit 1
		fi
    fi

    # Change owner of file
    chown $WM_USER:$WM_GROUP "$COPY_TARGET"
    RET=$?
    if [ $RET -ne 0 ]; then
		echo "Error while trying to change owner of '$COPY_TARGET' to $WM_USER:$WM_GROUP" >&2
		exit 1
    fi

    # Set access rights
    chmod $WM_FILE_ACCESSS_BIN "$COPY_TARGET"
    RET=$?
    if [ $RET -ne 0 ]; then
		echo "Error while trying to set access rights of '$COPY_TARGET' to $WM_FILE_ACCESSS_BIN" >&2
		exit 1
    fi


    # -----------------------
    # Create config file /etc/webmethods1015.cfg or ~/.webmethods1015
    # -----------------------
    if [ -e "$WM_CFG" ]; then
		create_backup "$WM_CFG"
    fi

    # Create empty file
    touch "$WM_CFG"
    RET=$?
    if [ $RET -ne 0 ]; then
		echo "Error while trying to create empty file '$WM_CFG'" >&2
		exit 1
    fi

    # Write to file
    echo "WM_ROOT=$WM_ROOT" > "$WM_CFG"
    echo "WM_USER=$WM_USER" >> "$WM_CFG"
    echo "WM_GROUP=$WM_GROUP" >> "$WM_CFG"
    echo "SHUTDOWN_MAX_WAIT_RETRIES=20" >> "$WM_CFG"
    echo "SHUTDOWN_WAIT_INTERVAL=5" >> "$WM_CFG"
    echo "# The following components could be handled by cluster software." >> "$WM_CFG"
    echo "# In that case uncomment the following two lines and remove the one with empty values" >> "$WM_CFG"
    echo "#IGNORE_START=\"brk idc ino\"" >> "$WM_CFG"
    echo "#IGNORE_STOP=\"brk idc ino\"" >> "$WM_CFG"
    echo "IGNORE_START=\"\"" >> "$WM_CFG"
    echo "IGNORE_STOP=\"\"" >> "$WM_CFG"
    echo "# On working with 'all' parameter, the following sequence of components are used" >> "$WM_CFG"
    echo "ALL_START_ORDER=\"spm tsa brk um is ae idc wsdc mws smh ino ctp od cce\"" >> "$WM_CFG"
    echo "ALL_STOP_ORDER=\"cce spm od mws wsdc idc ae is brk um ctp ino smh tsa \"" >> "$WM_CFG"
    echo "ALL_DEPENDENT_COMP_ORDER=\"mzcl mz\"" >> "$WM_CFG"
    echo "LOG_VIEWER=less" >> "$WM_CFG"
    RET=$?
    if [ $RET -ne 0 ]; then
		echo "Error while trying to write to '$WM_CFG'" >&2
		exit 1
    fi

    # Change owner of file
    chown $WM_USER:$WM_GROUP "$WM_CFG"
    RET=$?
    if [ $RET -ne 0 ]; then
		echo "Error while trying to change owner of '$WM_CFG' to $WM_USER:$WM_GROUP" >&2
		exit 1
    fi

    # Set access rights
    chmod $WM_FILE_ACCESSS_CFG "$WM_CFG"
    RET=$?
    if [ $RET -ne 0 ]; then
		echo "Error while trying to set access rights of '$WM_CFG' to $WM_FILE_ACCESSS_CFG" >&2
		exit 1
    fi

    install_symlinks "$WM_ROOT"

    install_aliases "$WM_ROOT"

}





# ===================================================
#  Get PID of component
# ===================================================
function pid() {
    COMP=$1
    index1=0
    for i in ${WM_COMP[@]}
    do
		if [ "$1" == ${WM_COMP[$index1]} ]; then
			MATCHES_PROC_PATTERN=`ps aux ww | grep -v -w grep | grep "${PROC_PATTERN[$index1]}" | wc -l`
			if [ $MATCHES_PROC_PATTERN -eq 0 ]; then
				echo "Not running"
				exit 0
			elif [ $MATCHES_PROC_PATTERN -eq 1 ]; then
				COMP_PID=`ps aux ww | grep -v -w grep | grep "${PROC_PATTERN[$index1]}" | awk '{ print $2}'`
				return $COMP_PID
			else
				echo "More than one process was found matching the pattern '${PROC_PATTERN[$index1]}'" >&2
				exit 1
			fi
		fi
		(( index1 = index1 + 1 ))
    done
    echo "Unknown component $1 specified" >&2
    exit 1
}




# ===================================================
#  Get status of component(s)
# ===================================================
function status_code() {
    index1=0
    for i in ${WM_COMP[@]}
    do
		if [ "$1" == ${WM_COMP[$index1]} ]; then
			STATUS=`ps aux ww | grep -v -w grep | grep "${PROC_PATTERN[$index1]}" >/dev/null 2>&1; echo $?`
			return $STATUS
		fi
		(( index1 = index1 + 1 ))
    done
    echo "Unknown component $1 specified" >&2
    exit 1
}

function status() {
    if [ $1 == "all" ]; then
		index=0
		for i in ${WM_COMP[@]}; do
			CMD_PRG=`echo "${CMD_START[$index]}" | awk '{print $1}'`
			if [ -f "$WM_ROOT/${CMD_DIR[$index]}/${CMD_PRG}" ]; then
				status_code $i
				RET=$?
				if [ $RET -eq 0 ]; then
					RET_TEXT="up"
				else
					RET_TEXT="down"
				fi
				get_component_index $i
				printf "%-30s : %s\n" "${COMP_NAME[$?]}" $RET_TEXT
			fi
			(( index = index + 1 ))
		done
    else
		status_code $1
		RET=$?
		if [ $RET -eq 0 ]; then
			echo "up"
		else
			echo "down"
		fi
    fi
}

# ===================================================
#  Start all components defined in START_ORDER
# ===================================================
function start_all() {
    for i in ${ALL_START_ORDER}
    do
	    start $i
    done
}



# ===================================================
#  Execute a command, taking into account whether
#  you are root or the provided user. Other users
#  are not allowed to initiate any action
# ===================================================
function run_cmd() {
    USERID=$1
    CMD=$2
   # Check whether this operation is performed as root
    WHOAMI=`whoami`
    if [ "$WHOAMI" == "root" ]; then
		su -l $USERID -c "$CMD"
    elif [ "$WHOAMI" == "$USERID" ]; then
		bash -c "$CMD"
    else
		echo "You must run this as user 'root' or '$USERID'" >&2
		exit 1
    fi
}


# ===================================================
#  Start a component
# ===================================================
function start() {
    COMP=$1
    
    if [ `echo "$IGNORE_START" | grep "$COMP" > /dev/null; echo $?` -ne 0 ]; then
		index=0
		for i in ${WM_COMP[@]}
		do
			if [ "$COMP" == ${WM_COMP[$index]} ]; then
				status_code $COMP
				STATUS=$?
				if [ $STATUS -eq 0 ]; then
					echo "${COMP_NAME[$index]} is already running"
				else
					# Check for lockfiles
					if [ ! -z ${WM_LOCKFILE[$index]} ]; then
						if [ -e "$WM_ROOT/${WM_LOCKFILE[$index]}" ]; then
							echo "Removing stale lockfile ${WM_LOCKFILE[$index]}"
							rm -f "$WM_ROOT/${WM_LOCKFILE[$index]}"
							RET=$?
							if [ $RET -ne 0 ]; then
								echo "Could not remove lockfile (RC=$RET)" >&2
								exit 1
							fi
						fi
					fi
					
					# Issue the START command
					echo "Starting ${COMP_NAME[$index]} ..."
					
					run_cmd ${PS_USERID[$index]} "cd $WM_ROOT/${CMD_DIR[$index]}; nohup ${CMD_START[$index]} & >/dev/null 2>&1"

					# Create lockfile if you are root
					WHOAMI=`whoami`
					if [ "$WHOAMI" == "root" ]; then
						touch /var/lock/subsys/wm_${WM_COMP[$index]}
					fi
				fi
				return 0
			fi
			(( index = index + 1 ))
		done
		echo "Unknown component specified: $COMP" >&2
		exit 1
    else
		echo "Start of component '$COMP' by this script is forbidden in $WM_CFG"
    fi
}

# ===================================================
#  Stop all components defined in STOP_ORDER
# ===================================================
function stop_all() {
    for i in ${ALL_STOP_ORDER}
    do
	    stop_kill $i stop
    done
}


# ===================================================
#  Stop/kill a component
# ===================================================
function stop_kill () {
    COMP=$1

    # Only if this is "kill", the script will (after explicit confirmation) kill the component
    CMD=$2

    if [ `echo "$IGNORE_STOP" | grep "$COMP" > /dev/null; echo $?` -ne 0 ]; then
		index=0
		for i in ${WM_COMP[@]}
		do
			if [ "$COMP" == ${WM_COMP[$index]} ]; then


				status_code $COMP
				STATUS=$?
				if [ $STATUS -ne 0 ]; then
					echo "${COMP_NAME[$index]} is not running"
				else
					if [ $CMD == "kill" ]; then
						if [ $FLAG_FORCE -ne 1 ]; then
							read -p "Do really want to kill '$COMP' (yes/no) [no]? " CONFIRM
						else
							CONFIRM="yes"
						fi
						if [ "$CONFIRM" == "yes" ]; then
							pid $PARAM
							kill -9 $COMP_PID
						else
							echo "Nothing done"
						fi
						return 0
					else

						# Issue the STOP command
						run_cmd ${PS_USERID[$index]} "cd $WM_ROOT/${CMD_DIR[$index]}; ${CMD_STOP[$index]}"
					fi

					WAIT_RETRIES=1

					while [ `ps aux ww | grep -v grep | grep -c "${PROC_PATTERN[$index]}"` -gt 0 ]; do
						echo "Shutdown of '$COMP' in progress, waiting $SHUTDOWN_WAIT_INTERVAL seconds before checking again $WAIT_RETRIES/$SHUTDOWN_MAX_WAIT_RETRIES"
						sleep $SHUTDOWN_WAIT_INTERVAL
						if [ $WAIT_RETRIES -eq $SHUTDOWN_MAX_WAIT_RETRIES ]; then
							echo "Maximum number of waits for shutdown reached"
							break
						fi
						(( WAIT_RETRIES = WAIT_RETRIES + 1 ))
					done

					# Remove lockfile if you are root
					WHOAMI=`whoami`
					if [ "$WHOAMI" == "root" ]; then
						rm -f /var/lock/subsys/wm_${WM_COMP[$index]}
					fi
				fi
				return 0
			fi
			(( index = index + 1 ))
		done
		echo "Unknown component specified: $COMP" >&2
		exit 1
    else
		echo "Stop of component '$COMP' by this script is forbidden in $WM_CFG"
    fi
}


# ===================================================
#  Get the index of component from short name
# ===================================================
function get_component_index() {
    COMP=$1

    index=0
    for i in ${WM_COMP[@]}
    do
		if [ "$COMP" == "${WM_COMP[$index]}" ]; then
			return $index
		fi
		(( index = index + 1 ))
    done
    echo "Component '$COMP' not found"
    exit 1
}


# ===================================================
#  Get name of a component's log file
# ===================================================
function logfile() {
    COMP=$1
    LEVEL=$2

    index=0
    for i in ${WM_COMP[@]}
    do
		if [ "$COMP" == ${WM_COMP[$index]} ]; then
			
			# Determine relative path and name of log file,
			# according to required level of detail
			if [ "$LEVEL" == "long" ]; then
				LOG_FILE_RELATIVE="${LOG_DIR_LONG[$index]}/${LOG_FILE_LONG[$index]}"
			else
				LOG_FILE_RELATIVE="${LOG_DIR_SHORT[$index]}/${LOG_FILE_SHORT[$index]}"
			fi

			# Abort if no log file defined for required level of detail
			if [ "$LOG_FILE_RELATIVE" == "/" ]; then
				echo "No logfile defined" >&2
				exit 1
			fi

			# Build absolute path of log file
			LOG_FILE="$WM_ROOT/$LOG_FILE_RELATIVE"
			
			LOG_FILE_EXISTS=`find $LOG_FILE >/dev/null 2>&1 ; echo $?`
			if [ "$LOG_FILE_EXISTS" -eq 0 ]; then
				return 0
			else
				echo "Log file '$LOG_FILE' does not exist. This usually means that this component is either not installed or has never been started" >&2
				exit 1
			fi
		fi
		(( index = index + 1 ))
    done
    echo "Unknown component specified: $COMP" >&2
    exit 1
}

# ===================================================
#  View a component's log file
# ===================================================
function logview() {
    COMP=$1
    LEVEL=$2

    logfile $COMP $LEVEL
    $LOG_VIEWER $LOG_FILE
}

# ===================================================
#  Stop and start a component
# ===================================================
function restart() {
    stop_kill $PARAM stop
    RETVAL=$?
    if [ $RETVAL -eq 0 ]; then
		start $PARAM
    else
		echo "Error repotted while trying to shut down '$PARAM': $RETVAL" >&2
    fi
}


# ===================================================
#  Print usage of this script
# ===================================================
function print_usage() {
    echo $"Usage: $PRG {start|stop|restart|status|pid} component"
    echo $"       $PRG [-f] kill component"
    echo $"       $PRG {log|logfull} component"
    echo $"       $PRG {logfile|logfilefull} component"
    echo $"       $PRG status [component]"
    echo $"       $PRG [-f] install WM_ROOT"
    echo $"       $PRG install_symlinks WM_ROOT"
    echo $"       $PRG uninstall_symlinks WM_ROOT"
    echo $"       $PRG install_aliases WM_ROOT"
    echo $"       $PRG uninstall_aliases"
    echo $"       "
    echo $"       Installed components: "
    index=0
    for i in ${WM_COMP[@]}; do
		CMD_PRG=`echo "${CMD_START[$index]}" | awk '{print $1}'`
		if [ -f "$WM_ROOT/${CMD_DIR[$index]}/${CMD_PRG}" ]; then
			printf "                   %-10s = %s\n" ${WM_COMP[$index]}  "${COMP_NAME[$index]}"
		fi
		(( index = index + 1 ))
    done
}




# Process optional parameters
FLAG_FORCE=0
while getopts 'vfc:u:g:' OPTION
do
    case $OPTION in
	v)	OUTPUT_VERBOSE=1
	    ;;
	f)	FLAG_FORCE=1
	    ;;
	c)	WM_CFG_MANUAL=$OPTARG
	    FLAG_WM_CFG=1
	    ;;
	u)	WM_USER=$OPTARG
	    echo "User changed to $WM_USER"
	    ;;
	g)	WM_GROUP=$OPTARG
	    echo "Group changed to $WM_GROUP"
	    ;;
	?)  echo "Wrong option"
	    print_usage
	    exit 1
	    ;;
    esac
done
shift $(($OPTIND - 1))


# Get cmdline params
CMD="$1"
PARAM="$2"

# Read config files for all commands other than "install"
if [ "$CMD" != "install" ]; then

    # If config file was specified on command line, use it
    if [ ! -z $WM_CFG_MANUAL ]; then
		read_cfg "$WM_CFG_MANUAL"
    else

	# Otherwise read standard global and wM user config files
		if [ -e "$WM_CFG_ROOT" ]; then
			read_cfg "$WM_CFG_ROOT"
		fi

		if [ -e "$WM_CFG_NONROOT" ]; then
			read_cfg "$WM_CFG_NONROOT"
		fi
    fi
fi



# Check whether this operation is performed as root
WHOAMI=`whoami`
if [ "$WHOAMI" == "root" ]; then
    WM_CFG=$WM_CFG_ROOT
    PROFILE_DIR=$PROFILE_DIR_ROOT
    PROFILE_WM=$PROFILE_WM_ROOT
elif [ "$WHOAMI" == "$WM_USER" ]; then
    WM_CFG=$WM_CFG_NONROOT
    PROFILE_DIR=$PROFILE_DIR_NONROOT
    PROFILE_WM=$PROFILE_WM_NONROOT
else
    output err "You must run this as user 'root' or '$WM_USER'"
    abort 1
fi


# Override config file, if specified explicitly
if [ ! -z $WM_CFG_MANUAL ]; then
    WM_CFG=$WM_CFG_MANUAL
fi

# Show relevant config files
output debug "Config  file = $WM_CFG"
output debug "Aliases file = $PROFILE_WM"


# Component abbreviation for start|stop|status
WM_COMP[0]=is
WM_COMP[1]=brk
WM_COMP[2]=ae
WM_COMP[3]=wsdc
WM_COMP[4]=mws
WM_COMP[5]=idc
WM_COMP[6]=ino
WM_COMP[7]=ctp
WM_COMP[8]=smh
WM_COMP[9]=tsa
WM_COMP[10]=od
WM_COMP[11]=um
WM_COMP[12]=spm
WM_COMP[13]=cce
WM_COMP[14]=mzcl
WM_COMP[15]=mz
WM_COMP[16]=msr
 
# Speaking name of component for status overview
COMP_NAME[0]="Integration Server"
COMP_NAME[1]="Broker"
COMP_NAME[2]="Analytic Engine"
COMP_NAME[3]="Web Service Data Collector"
COMP_NAME[4]="My webMethods Server"
COMP_NAME[5]="Infrastructure Data Collector"
COMP_NAME[6]="CentraSite DB"
COMP_NAME[7]="Common Runtime"
COMP_NAME[8]="CentraSite SMH"
COMP_NAME[9]="Terracotta Server Array"
COMP_NAME[10]="OneData"
COMP_NAME[11]="Universal Messaging"
COMP_NAME[12]="Platform Manager"
COMP_NAME[13]="Command Central"
COMP_NAME[14]="Mashzone Cloud Agent"
COMP_NAME[15]="Mashzone Server"
COMP_NAME[16]="Microservices Runtime"
 
# LOCKFILE to check (if applicable)
WM_LOCKFILE[0]="profile/IS_default/bin/.lock"
WM_LOCKFILE[1]=""
WM_LOCKFILE[2]=""
WM_LOCKFILE[3]=""
WM_LOCKFILE[4]=""
WM_LOCKFILE[5]="InfrastructureDC/LOCKFILE"
WM_LOCKFILE[6]=""
WM_LOCKFILE[7]=""
WM_LOCKFILE[8]=""
WM_LOCKFILE[9]=""
WM_LOCKFILE[10]=""
WM_LOCKFILE[11]=""
WM_LOCKFILE[12]="" 
WM_LOCKFILE[13]="" 
WM_LOCKFILE[14]="" 
WM_LOCKFILE[15]=""
WM_LOCKFILE[16]="IntegrationServer/bin/.lock"

# These are the pattern that are looked for when determining whether
# a component is running or not. Also, during component shutdown
# the script will wait until this pattern cannot be found among
# running processes any more (or the max. number of tries has been
# reached). The pattern should NOT match any running 
# display commands to show log files, e.g tail.
PROC_PATTERN[0]="-service sagis1015"
PROC_PATTERN[1]="awbroker -d"
PROC_PATTERN[2]="analysis/conf"
PROC_PATTERN[3]="dataCollector/conf"
PROC_PATTERN[4]="profiles/MWS_default/configuration"
PROC_PATTERN[5]="profiles/InfraDC/configuration"
PROC_PATTERN[6]="CentraSite/bin/inosrv"
PROC_PATTERN[7]="profiles/CTP/configuration c"
PROC_PATTERN[8]="InstanceManager/conf"
PROC_PATTERN[9]="com.tc.server.TCServerMain"
PROC_PATTERN[10]="profiles/ODE/configuration com.softwareag.osgi.Bootstrap"
PROC_PATTERN[11]="\-DREALM=umserver"
PROC_PATTERN[12]="./sagspm1015.pid"
PROC_PATTERN[13]="./sagcce1015.pid"
PROC_PATTERN[14]="wrapper.name=PPMMashZoneCloudAgent"
PROC_PATTERN[15]="ppmmashzone/server/bin/work/work_mashzone_[s|m|l]"
PROC_PATTERN[16]="IntegrationServer"

# Directory to cd to before running start/stop command
CMD_DIR[0]="IntegrationServer/instances/default/bin"
CMD_DIR[1]="Broker"
CMD_DIR[2]="optimize/analysis/bin"
CMD_DIR[3]="optimize/dataCollector/bin"
CMD_DIR[4]="MWS/bin"
CMD_DIR[5]="InfrastructureDC/bin"
CMD_DIR[6]="CentraSite/apache2/bin"
CMD_DIR[7]="profiles/CTP/bin"
CMD_DIR[8]="InstanceManager/bin"
CMD_DIR[9]="Terracotta/bin"
CMD_DIR[10]="profiles/ODE/bin"
CMD_DIR[11]="UniversalMessaging/server/umserver/bin"
CMD_DIR[12]="profiles/SPM/bin"
CMD_DIR[13]="profiles/CCE/bin"
CMD_DIR[14]="ppmmashzone/server/bin"
CMD_DIR[15]="ppmmashzone/server"
CMD_DIR[16]="IntegrationServer/bin"
 
# Command to start a component
CMD_START[0]="./startup.sh"
CMD_START[1]="./aw_broker1015 start"
CMD_START[2]="./startup.sh"
CMD_START[3]="./startup.sh"
CMD_START[4]="./mws.sh start"
CMD_START[5]="./startup.sh"
CMD_START[6]="./apachectl start"
CMD_START[7]="./startup.sh"
CMD_START[8]="./startup.sh"
CMD_START[9]="./start-tc-server.sh"
CMD_START[10]="./startup.sh"
CMD_START[11]="./nserverdaemon start"
CMD_START[12]="./startup.sh"
CMD_START[13]="./startup.sh"
CMD_START[14]="./CloudAgentApp.sh start"
CMD_START[15]="./start_mashzone.sh"
CMD_START[16]="./startup.sh"

# Command to stop a component
CMD_STOP[0]="./shutdown.sh"
CMD_STOP[1]="./aw_broker1015 stop"
CMD_STOP[2]="./shutdown.sh"
CMD_STOP[3]="./shutdown.sh"
CMD_STOP[4]="./mws.sh stop"
CMD_STOP[5]="./shutdown.sh"
CMD_STOP[6]="./apachectl stop"
CMD_STOP[7]="./shutdown.sh"
CMD_STOP[8]="./shutdown.sh"
CMD_STOP[9]="./stop-tc-server.sh"
CMD_STOP[10]="./shutdown.sh"
CMD_STOP[11]="./nserverdaemon stop"
CMD_STOP[12]="./shutdown.sh"
CMD_STOP[13]="./shutdown.sh"
CMD_STOP[14]="./CloudAgentApp.sh stop"
CMD_STOP[15]="./stop_mashzone.sh"
CMD_STOP[16]="./shutdown.sh"

# Configure log viewing
LOG_DIR_LONG[0]="profiles/IS_default/logs"
LOG_DIR_LONG[1]=""
LOG_DIR_LONG[2]="optimize/analysis/logs"
LOG_DIR_LONG[3]="optimize/dataCollector/logs"
LOG_DIR_LONG[4]="MWS/server/default/logs"
LOG_DIR_LONG[5]="profiles/InfraDC/logs"
LOG_DIR_LONG[6]=""
LOG_DIR_LONG[7]=""
LOG_DIR_LONG[8]=""
LOG_DIR_LONG[9]="terracotta-ee*/logs/server-logs"
LOG_DIR_LONG[10]="profiles/ODE/bin/onedata"
LOG_DIR_LONG[11]="UniversalMessaging/server/umserver/data"
LOG_DIR_LONG[12]="profiles/SPM/logs"
LOG_DIR_LONG[13]="profiles/CCE/logs"
LOG_DIR_LONG[14]="ppmmashzone/server/logs"
LOG_DIR_LONG[15]="ppmmashzone/server/bin/work/work_mashzone_*/base/logs"
LOG_DIR_LONG[16]=""

LOG_DIR_SHORT[0]="IntegrationServer/instances/default/logs"
LOG_DIR_SHORT[1]="${LOG_DIR_LONG[1]}"
LOG_DIR_SHORT[2]="${LOG_DIR_LONG[2]}"
LOG_DIR_SHORT[3]="${LOG_DIR_LONG[3]}"
LOG_DIR_SHORT[4]="${LOG_DIR_LONG[4]}"
LOG_DIR_SHORT[5]="${LOG_DIR_LONG[5]}"
LOG_DIR_SHORT[6]="${LOG_DIR_LONG[6]}"
LOG_DIR_SHORT[7]="${LOG_DIR_LONG[7]}"
LOG_DIR_SHORT[8]="${LOG_DIR_LONG[8]}"
LOG_DIR_SHORT[9]="${LOG_DIR_LONG[9]}"
LOG_DIR_SHORT[10]="${LOG_DIR_LONG[10]}"
LOG_DIR_SHORT[11]="${LOG_DIR_LONG[11]}"
LOG_DIR_SHORT[12]="${LOG_DIR_LONG[12]}"
LOG_DIR_SHORT[13]="${LOG_DIR_LONG[13]}"
LOG_DIR_SHORT[14]="${LOG_DIR_LONG[14]}"
LOG_DIR_SHORT[15]="${LOG_DIR_LONG[15]}"
LOG_DIR_SHORT[16]="IntegrationServer/logs"

 
LOG_FILE_LONG[0]="sag-osgi.log"
LOG_FILE_LONG[1]=""
LOG_FILE_LONG[2]="info.log"
LOG_FILE_LONG[3]="info.log"
LOG_FILE_LONG[4]="_full_.log"
LOG_FILE_LONG[5]="sag-osgi.log"
LOG_FILE_LONG[6]=""
LOG_FILE_LONG[7]=""
LOG_FILE_LONG[8]=""
LOG_FILE_LONG[9]="terracotta-server.log"
LOG_FILE_LONG[10]="wrapper.log"
LOG_FILE_LONG[11]="nirvana.log"
LOG_FILE_LONG[12]="info.log"
LOG_FILE_LONG[13]="info.log"
LOG_FILE_LONG[14]="CloudAgent.log"
LOG_FILE_LONG[15]="MashZone.log"
LOG_FILE_LONG[16]=""
 
LOG_FILE_SHORT[0]="server.log"
LOG_FILE_SHORT[1]=""
LOG_FILE_SHORT[2]="error.log"
LOG_FILE_SHORT[3]="error.log"
LOG_FILE_SHORT[4]="_problems_.log"
LOG_FILE_SHORT[5]="sag-osgi.log"
LOG_FILE_SHORT[6]=""
LOG_FILE_SHORT[7]=""
LOG_FILE_SHORT[8]=""
LOG_FILE_SHORT[9]="terracotta-server.log"
LOG_FILE_SHORT[10]="wrapper.log"
LOG_FILE_SHORT[11]="nirvana.log"
LOG_FILE_SHORT[12]="error.log"
LOG_FILE_SHORT[13]="error.log"
LOG_FILE_SHORT[14]=""
LOG_FILE_SHORT[15]=""
LOG_FILE_SHORT[16]="server.log"

# Process user
PS_USERID[0]=${WM_USER}
PS_USERID[1]=${WM_USER}
PS_USERID[2]=${WM_USER}
PS_USERID[3]=${WM_USER}
PS_USERID[4]=${WM_USER}
PS_USERID[5]=${WM_USER}
PS_USERID[6]=${WM_USER}
PS_USERID[7]=${WM_USER}
PS_USERID[8]=${WM_USER}
PS_USERID[9]=${WM_USER}
PS_USERID[10]=${WM_USER}
PS_USERID[11]=${WM_USER}
PS_USERID[12]=${WM_USER}
PS_USERID[13]=${WM_USER}
PS_USERID[14]=${WM_USER}
PS_USERID[15]=${WM_USER}
PS_USERID[16]=${WM_USER}



# If script was not started as "$PRG_NAME" (e.g. webmethods1015.sh), determine
# if it was one of the created symlinks and derive the
# relevant component name from there if possible
if [ "$PRG" != "$PRG_NAME" ]; then
    if [ "$CMD" == "install" ]; then
	echo "Script must be started under name $PRG_NAME for 'install' to be a valid parameter" >&2
	exit 1
    fi
    index=0
    for i in ${WM_COMP[@]}
    do
	if [ "$PRG" == "wm_${WM_COMP[$index]}" ]; then
	    PARAM=${WM_COMP[$index]}
	    break
	fi
	(( index = index + 1 ))
    done
fi



case "$CMD" in
    start)
        if [ "$PARAM" == "all" ]; then
	        start_all
        else
	        start $PARAM
        fi
        RETVAL=$?
        ;;
    stop)
        if [ "$PARAM" == "all" ]; then
	        stop_all
        else
            stop_kill $PARAM stop
        fi
        RETVAL=$?
        ;;
    restart)
         restart $PARAM
         ;;
    kill)
        stop_kill $PARAM kill
        RETVAL=$?
        ;;
    status)
		if [ -z $PARAM ]; then
			PARAM="all"
		fi
        status $PARAM
        RETVAL=$?
        ;;
    pid)
        pid $PARAM
		echo $COMP_PID
        RETVAL=$COMP_PID
        ;;
    log)
        logview $PARAM short
        RETVAL=$?
        ;;
    logfull)
        logview $PARAM long
        RETVAL=$?
        ;;
    logfile)
        logfile $PARAM short
		echo "$LOG_FILE"
        RETVAL=$?
        ;;
    logfilefull)
        logfile $PARAM long
		echo "$LOG_FILE"
        RETVAL=$?
        ;;
    pid)
		pid $PARAM
		echo $?
		;;
    cd)
        cd $WM_ROOT
        RETVAL=$?
        ;;
    install)
        install "$PARAM"
        RETVAL=$?
        ;;
    install_aliases)
        install_aliases "$PARAM"
        RETVAL=$?
        ;;
    uninstall_aliases)
        uninstall_aliases
        RETVAL=$?
        ;;
    install_symlinks)
        install_symlinks "$PARAM"
        RETVAL=$?
        ;;
    uninstall_symlinks)
        uninstall_symlinks "$PARAM"
        RETVAL=$?
        ;;
    *)
	print_usage
        exit 1
        ;;
esac

exit $RETVAL
