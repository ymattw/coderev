# Homepage: http://code.google.com/p/coderev
# License: GPLv2, see "COPYING"
#
# This library implements svn operations, see comments in coderev.sh
#
# $Id: libsvn.sh 38 2010-01-12 10:03:08Z mattwyl $

function svn_get_banner
{
    echo "Subversion"
    return 0
}

function svn_get_repository
{
    svn info . | grep '^Repository Root:' | cut -c18-
}

function svn_get_project_path
{
    local root=$(svn_get_repository)
    local url=$(svn info . | grep '^URL:' | cut -c6-)
    echo ${url#${root}/}
}

function svn_get_working_revision
{
    local pathname="."
    [[ -n $1 ]] && [[ -z $2 ]] && pathname=$1
    svn info $pathname | grep '^Revision:' | cut -c11-
}

function svn_get_active_list
{
    # svn 1.5 has 6 columns plus a space while svn 1.6+ has 6 columns
    svn st $@ | grep '^[A-Z]' | cut -c8- | sed 's/^ *//'
}

function svn_get_diff
{
    local op diff_opt OPTIND OPTARG

    while getopts "r:" op; do
        case $op in
            r) diff_opt="-r $OPTARG" ;;
            ?) echo "Unknown option: -$op" >&2; exit 1;;
        esac
    done
    shift $((OPTIND - 1))

    # patch utility sometimes fails if no context line
    # Issue 2 suffers by keywords in context
    svn diff --diff-cmd /usr/bin/diff -x -U5 $diff_opt $@ \
        | sed '/^Property changes on:/,/^$/d' | grep -v '^$'
}

function svn_get_diff_opt
{
    echo "-r $1"
}
