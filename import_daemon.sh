#!/bin/bash
 
# EMAN2 Import Daemon Version 20160907_1
# written by chris
 
 
 
# Usage: ./import_daemon.sh 
# --source= / -s
# --dest= / -d
# --watch= / -w
# --action= / -a (cp, mv, list)
# *--remote= allows to perform the action on a remote host (via ssh; not with --action=list)
# --ext= / -e
# --other= defines other file endings to be copied/moved/listed along with the .EXT file. can be like .log or _movie.mrcs
# takes them as a list separated by comma ',' if there is more than one
 
## cmd line parser for arguments
for i in "$@"
do
case $i in
    -s=*|--source=*)
    SRC="${i#*=}"
    shift # past argument
    ;;
    -d=*|--dest=*)
    DEST="${i#*=}"
    shift # past argument
    ;;
    -w=*|--watch=*)
    WATCH="${i#*=}"
    shift # past argument
    ;;
    -a=*|--action=*)
    ACTION="${i#*=}"
    shift # past argument
    ;;
    --remote=*)
    REMOTE="${i#*=}"
    shift # past argument
    ;;
    --other=*)
    OTHER="${i#*=}"
    shift # past argument
    ;;
    -e=*|--ext=*)
    EXT="${i#*=}"
    ;;
    *)
            # unknown option
    ;;
esac
shift # past argument or value
done
 
# creaete the list if needed
if [ "$ACTION" == "list" ] && [ ! -e import_list.txt ]; then
	echo Creating import_list.txt
	> import_list.txt
	echo Done.
fi
 
echo -------------------------
echo EMAN2 Import Daemon
echo written by Chris
echo -------------------------
echo 'Waiting for imported micrographs...' 
 
### daeomon here
while [ 1 ]
do
	# watch hdf-files in WATCH
	for file in $WATCH/*.hdf
	do
 
		# remove the .hdf to get a clean file name
		name=`echo ${file}| sed 's|.hdf||'`
		name="${name##*/}"
		if [[ -e $SRC/$name.$EXT ]] && [ "$name" != "*" ]; then
			if [ "$ACTION" == "cp" ]; then
				if [ ! -e $DEST/$name.$EXT ]; then
					echo $name.$EXT was imported.
					echo Copying $name.$EXT to $DEST
					cp $SRC/$name.$EXT $DEST/$name.$EXT
					if [ ! -z ${OTHER+x} ]; then
						oth=$(echo $OTHER | tr "," "\n")
						for item in $oth
						do
						    echo "$name$item needs to be copied as well."
						    cp $SRC/$name$item $DEST/$name$item
						done	
					fi
					echo Done.
				fi
			elif [ "$ACTION" == "mv" ]; then
				if [ ! -e $DEST/$name.$EXT ]; then
					echo $name.$EXT was imported.
					echo Moving $name.$EXT to $DEST
					mv $SRC/$name.$EXT $DEST/$name.$EXT
					if [ ! -z ${OTHER+x} ]; then
						oth=$(echo $OTHER | tr "," "\n")
						for item in $oth
						do
						    echo "$name$item needs to be moved as well."
						    mv $SRC/$name$item $DEST/$name$item
						done	
					fi
					echo Done.
				fi
			elif [ "$ACTION" == "list" ]; then
				if ! grep -Fxq "$name.$EXT" import_list.txt; then
					echo $name.$EXT was imported.
					echo Adding $name.$EXT to import_list.txt
					echo $name.$EXT >> import_list.txt
					if [ ! -z ${OTHER+x} ]; then
						oth=$(echo $OTHER | tr "," "\n")
						for item in $oth
						do
						    echo "$name$item needs to be listed as well."
						    echo $name.$item >> import_list.txt
						done	
					fi
					echo Done.
				fi
			else
				echo "User uses 'undefined action'. Import daemon is confused. Import daemon does not know what to do."
				exit 1
			fi
		fi
		# not sure if the belwo is compatible with EMAN2.
		# Need to do more tests on that. Might be enabled later.
 
		# check filesize of the hdf and if > 0 override with 0 to not flood the local drive with data
		#if [ -e $file ]; then
		#	filesize=$(stat -c%s "$file")
		#	if [ $filesize > 0 ]; then
		#	> $file
		#	fi
		#fi
	done
		# back check if there is sth unimported
		if [ "$ACTION" == "cp" ] || [ "$ACTION" == "mv" ]; then
			for thing in $DEST/*.mrc
			do
				name=`echo ${thing}| sed "s/.$EXT//"`
				name="${name##*/}"
				# check if there is unimported stuff and move back the mrc
				if [ ! -e $WATCH/$name.hdf ] && [ -f $DEST/$name.$EXT ]; then
					echo $name.$EXT was unimported.
					echo Removing $name.$EXT from $DEST
					if [ "$ACTION" == "cp" ]; then
						rm -f $DEST/$name.$EXT
						if [ ! -z ${OTHER+x} ]; then
							o=$(echo $OTHER | tr "," "\n")
							echo "Also removing associated files:"
							for item in $o
							do
								if [ -e $DEST/$name$item ]; then
									echo "$name$item"
									rm -f $DEST/$name$item
								else
									echo "Associated file $name$item does not exist in $DEST."
								fi
							done	
						fi	
					elif [ "$ACTION" == "mv" ]; then
						mv $DEST/$name.$EXT $SRC/$name.$EXT
						if [ ! -z ${OTHER+x} ]; then
							o=$(echo $OTHER | tr "," "\n")
							echo "Also removing associated files:"
							for item in $o
							do
								if [ -e $DEST/$name$item ]; then
									echo "$name$item"
									mv $DEST/$name$item $SRC/$name$item
								else
									echo "Associated file $name$item does not exist in $DEST."
								fi
							done	
						fi
					fi
					echo Done.
				fi
 
			done
		elif [ "$ACTION" == "list" ]; then
			# read the file
			echo '' > temp.import
			while read l; do
				name=`echo ${l}| sed "s/.$EXT//"`
				name="${name##*/}"
				if [ "$name" != "" ] && [ "${l##*.}" == "$EXT" ]; then 
		 			if [[ -e $WATCH/$name.hdf ]]; then
		 				echo $name.$EXT >> temp.import
		 				if [ ! -z ${OTHER+x} ]; then
							o=$(echo $OTHER | tr "," "\n")
							for item in $o
							do
								echo "$name$item" >> temp.import
							done	
						fi
					else
						echo "$name.$EXT was unimported."
						echo Removing $name.$EXT from import_list.txt
						if [ ! -z ${OTHER+x} ]; then
							echo "Also removing associated files."
						fi
						echo Done. 			
					fi
				fi
			done <import_list.txt
			mv temp.import import_list.txt
		else
			echo "User uses 'undefined action'. Import daemon is confused. Import daemon does not know what to do."
			exit 1
		fi
	sleep 1
done


