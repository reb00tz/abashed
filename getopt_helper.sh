#!/bin/bash

# getopt_helper.sh v1.0 from https://www.thestuffweuse.com/2019/03/31/gnu-getopt-needs-a-helper/

if [ ${#SHORTOPTLIST[@]} -eq 0 ] || \
   [ ${#LONGOPTLIST[@]} -eq 0 ] || \
   [ ${#OPTARGLIST[@]}  -eq 0 ] || \
   [ ${#ARGVARLIST[@]}  -eq 0 ] || \
   [ ${#OPTIONUSAGE[@]} -eq 0 ]; then
  echo "INVALID OVERRIDDEN LIST OPTION ARRAYS - USING DEFAULT/DEMO!"
  DEFAULTDEMO=true

##############################################################
# copy and override options, arguments and description lists #
##############################################################

# short option list
SHORTOPTLIST=(
  "h"
  "a"
  "b"
  "c"
  "d"
  ""
)

# long option list
LONGOPTLIST=(
  "help"
  "longa"
  "longb"
  "longc"
  ""
  "longe"
)

# option argument list
OPTARGLIST=(
  ""
  ""
  ":"
  "::"
  "::"
  ":"
)

# argument variable names list
ARGVARLIST=(
  ""
  ""
  "VAR_B"
  "INPUT_C"
  "VARIABLE_D"
  "OPTION_E"
)

# usage list
OPTIONUSAGE=(
  "shows usage"
  "option a definition"
  "option b definition"
  "option c definition"
  "option d definition"
  "option e definition"
)

##############################################################
# end override template ######################################
##############################################################

fi

# ensure number of entries are equal across SHORTOPTLIST LONGOPTLIST, OPTARGLIST and OPTIONUSAGE
if [ ${#SHORTOPTLIST[@]} -ne ${#LONGOPTLIST[@]} ] || \
   [ ${#SHORTOPTLIST[@]} -ne ${#OPTARGLIST[@]} ] || \
   [ ${#SHORTOPTLIST[@]} -ne ${#ARGVARLIST[@]} ] || \
   [ ${#SHORTOPTLIST[@]} -ne ${#OPTIONUSAGE[@]} ]; then
  echo "ERROR IN OPTIONS LISTS! PLEASE CORRECT SCRIPT SOURCE!">&2;
  exit 255;
fi

# initialize strings
SHORTOPTS=""
LONGOPTS=""

# sanity check on (1) short/long options, (2) OPTARGLIST[] vs. ARGVARLIST[], then build option strings for getopt()
for index in "${!SHORTOPTLIST[@]}"; do
  # check that at least one of SHORTOPTLIST[x] or LONGOPTLIST[x] is defined
  if [ -z ${SHORTOPTLIST[$index]} ] && [ -z ${LONGOPTLIST[$index]} ]; then echo "EMPTY SHORT AND LONG OPTION COMBINATION FOUND! PLEASE CHECK SOURCE SCRIPT!">&2; exit 255; fi;

  # OPTARGLIST[x] has required or optional argument
  if [ "${OPTARGLIST[$index]}" == ":" ] || [ "${OPTARGLIST[$index]}" == "::" ]; then
    # ensure that ARGVARLIST[x] is set
    if [ -z "${ARGVARLIST[$index]}" ]; then echo "ARGVARLIST NOT SET PROPERLY! PLEASE CHECK SOURCE SCRIPT!">&2; exit 255; fi;
  # else if OPTARGLIST[x] has no arguments, ensure ARGVARLIST[x] is empty
  elif [ -z "${OPTARGLIST[$index]}" ] && [ ! -z "${ARGVARLIST[$index]}" ]; then
    echo "ARGVARLIST NOT SET PROPERLY! PLEASE CHECK SOURCE SCRIPT!">&2; exit 255;
  fi;

  # build options strings, including arguments (if any)
  if [ ! -z ${SHORTOPTLIST[$index]} ]; then SHORTOPTS=$SHORTOPTS`printf "%s%s" "${SHORTOPTLIST[$index]}" "${OPTARGLIST[$index]}"`; fi;
  if [ ! -z ${LONGOPTLIST[$index]} ]; then LONGOPTS=$LONGOPTS`printf "%s%s," "${LONGOPTLIST[$index]}" "${OPTARGLIST[$index]}"`; fi;
done

# remove trailing comma from LONGOPTS
#LONGOPTS=${LONGOPTS::-1}             # this works
#LONGOPTS=${LONGOPTS::${#LONGOPTS}-1} # this works too
LONGOPTS=${LONGOPTS%?}               # this also works

# print usage
function PRINTUSAGE {
  # PRINTDESC() override check:
  type PRINTDESC &>/dev/null
  if [ $? -ne 0 ]; then

##########################################
# copy and override PRINTDESC() function #
##########################################

function PRINTDESC {
  cat<<EOF

DEFAULT/DEMO DESCRIPTION FROM getopt_helper.sh
PLEASE OVERRIDE THE PRINTDESC() FUNCTION TO PRINT YOUR ACTUAL SCRIPT'S FUNCTION!

TO USE THIS HELPER SCRIPT, PLEASE COPY THE THREE "TEMPLATE" SECTIONS TO YOUR OWN
SCRIPT, EDIT TO SUIT THEN CALL `. $0` IN THE SAME ENVIRONMENT (NOTE THE PRECEDING
"."). PLEASE REFER TO THE getopt_helper_test.sh SAMPLE SCRIPT AVAILABLE AT
 https://www.thestuffweuse.com/2019/03/31/gnu-getopt-needs-a-helper/
EOF
}

#########################################
# end override template #################
#########################################

  fi
  PRINTDESC
  # get length of longest of SHORTOPTLIST[], LONGOPTLIST[] and ARGVARLIST[]
  LONGESTLONG=0
  LONGESTARGVAR=0
  for index in "${!SHORTOPTLIST[@]}"; do
    if [ ${#LONGOPTLIST[$index]} -gt $LONGESTLONG ]; then LONGESTLONG=${#LONGOPTLIST[$index]}; fi;
    if [ ${#ARGVARLIST[$index]} -gt $LONGESTARGVAR ]; then LONGESTARGVAR=${#ARGVARLIST[$index]}; fi;
  done
  LONGESTARGVAR=$((LONGESTARGVAR+3))  # add 3 to account for possible "[=" prefix and "]" suffix

  echo -e "\nUsage:"
  for index in "${!SHORTOPTLIST[@]}"; do
     if [ ! -z "${SHORTOPTLIST[$index]}" ]; then printf "  %s%s" "-" "${SHORTOPTLIST[$index]}"; else printf "    "; fi;
     if [ ! -z "${SHORTOPTLIST[$index]}" ] && [ ! -z "${LONGOPTLIST[$index]}" ]; then printf "|"; else printf " "; fi;
     if [ ! -z "${LONGOPTLIST[$index]}" ]; then printf "%s%-*s%s" "--" "$LONGESTLONG" "${LONGOPTLIST[$index]}" "  "; else printf "  %*s%s" "$LONGESTLONG" "" "  "; fi;
     if [ "${OPTARGLIST[$index]}" == "::" ]; then printf "%-*s%s" "$LONGESTARGVAR" "[=${ARGVARLIST[$index]}]" "  ";
     elif [ "${OPTARGLIST[$index]}" == ":" ]; then printf "%-*s%s" "$LONGESTARGVAR" " =${ARGVARLIST[$index]} " "  ";
     else
       printf "%-*s%s" "$LONGESTARGVAR" "" "  ";
     fi;
     printf "${OPTIONUSAGE[$index]}\n";

#    if [ ! -z "${SHORTOPTLIST[$index]}" ] && [ ! -z "${LONGOPTLIST[$index]}" ]; then
#      printf "  -%s|--%s\t\t%s\n" "${SHORTOPTLIST[$index]}" "${LONGOPTLIST[$index]}" "${OPTIONUSAGE[$index]}";
#    elif [ -z "${SHORTOPTLIST[$index]}" ] && [ ! -z "${LONGOPTLIST[$index]}" ]; then
#      printf "     --%s\t\t%s\n" "${LONGOPTLIST[$index]}" "${OPTIONUSAGE[$index]}";
#    elif [ ! -z "${SHORTOPTLIST[$index]}" ] && [ -z "${LONGOPTLIST[$index]}" ]; then
#      printf "  -%s\t\t\t%s\n" "${SHORTOPTLIST[$index]}" "${OPTIONUSAGE[$index]}";
#    else
#      echo "ERROR IN PARSING OPTIONSLISTS! PLEASE CORRECT SCRIPT SOURCE!";
#      exit 255;
#    fi
  done
  echo -e "\n"
}


# debug
function debug() { [ "$DEBUG" ] && echo ">>> $*"; }

# failed GNU getopt check
function REQGNUGETOPT {
cat<<EOF

This script requires the use of GNU getopt. It is either missing or your version is incompatible.

For Linux:
  Install the util-linux package, either by `yum install util-linux` or `aptget install util-linux` (dependent on distribution).

For Mac OSX:
  Install MacPorts (http://www.macports.org) and then do \`sudo port install getopt\` to install GNU getopt (usually into /opt/local/bin);
  and make sure that /opt/local/bin is in your shell path ahead of /usr/bin.

For FreeBSD:
  Install misc/getopt.

EOF
}

# test for GNU getopt, exit(1) if getopt missing
which getopt &>/dev/null; if [ $? -ne 0 ]; then REQGNUGETOPT >&2; exit 1; fi;
# test for GNU getopt compatibility, exit(1) if not GNU compatible
getopt -T &>/dev/null; if [ $? -ne 4 ]; then REQGNUGETOPT >&2; exit 1; fi;


# set getopt options list
GETOPTTEMP=`getopt -o "$SHORTOPTS" --long "$LONGOPTS" -n "$0" -- "$@"`

# errors in provided option(s), print usage and exit(1)
if [ $? != 0 ] ; then PRINTUSAGE >&2 ; exit 1 ; fi;

# (essential) quoted eval for $TEMP
eval set -- "$GETOPTTEMP"

if [ ! -z "$DEFAULTDEMO" ]; then

#########################################################################################
# copy and override options parsing - must be AFTER call to `. <path>/getopt_helper.sh` #
#########################################################################################

while true; do
  case "$1" in
    -h|--help)  PRINTUSAGE; exit 0;;
    -a|--longa) echo "Option a"; shift;;
    -b|--longb) echo "Option b, argument \`$2'"; shift 2;;
    -c|--longc)
      # c has an optional argument. As we are in quoted mode,
      # an empty parameter will be generated if its optional
      # argument is not found.
      case "$2" in
        "") echo "Option c, no argument"; shift 2;;
        *)  echo "Option c, argument \`$2'"; shift 2;;
      esac;;
    --) shift; break;;
      # "eat" the "--" separator generated by getopt, with any remaining non-recognised input processed outside loop
      # remove this "--" case if parsing of remaining input is required within this while/do/done loop
    *) echo "$1"; echo "INTERNAL ERROR!"; exit 1;;
  esac
done

#########################################################################################
# end override template #################################################################
#########################################################################################

  # any remaining non-recognised inputs are in $arg
  echo "Remaining arguments:"
  for arg do echo '--> '"\`$arg'" ; done

fi

