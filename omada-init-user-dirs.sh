#! /bin/bash
#
#  Initializes the Omada controller user directory.
#
###################################################


OMADA_USER="omada"
OMADA_GROUP="${USER}"
USER_DIR="/var/lib/omada-controller"
DATA_DIR="${USER_DIR}/data"
DATA_DB_DIR="${DATA_DIR}/db"
LOGS_DIR="${USER_DIR}/logs"
WORK_DIR="${USER_DIR}/work"
AUTOBACKUP_DIR="${DATA_DIR}/autobackup" 
USER_DIRS=(
    "${USER_DIR}"
    "${DATA_DIR}"
    "${DATA_DB_DIR}"
    "${LOGS_DIR}"
    "${WORK_DIR}"
    "${AUTOBACKUP_DIR}"
)
OMADA_HOME="/opt/omada-controller"
SYMLINKS=(
    "${DATA_DIR}"
    "${LOGS_DIR}"
    "${WORK_DIR}"
    "${AUTOBACKUP_DIR}"
)


create_user_directories() {
    for DIR in "${USER_DIRS[@]}"; do
        if [ -e "${DIR}" ]; then
            if [ ! -d "${DIR}" ]; then
                printf 'File "%s" is blocking creation of eponymous directory.' "${DIR}" >&2
                continue
            fi
        else
            mkdir "${DIR}"
        fi

        if [ "$(stat -c '%U.%G' "${DIR}")" != "${OMADA_USER}.${OMADA_GROUP}" ]; then
            chown "${OMADA_USER}:${OMADA_GROUP}" "${DIR}"
        fi
    done
}


create_symlinks() {
    if [ ! -d "${OMADA_HOME}" ]; then
        printf 'Omada home "%s" is missing.' "${OMADA_HOME}" >&2
        return 2
    fi

    for TARGET in "${SYMLINKS[@]}"; do
        if [ ! -e "${TARGET}" ]; then
            printf 'Link target "%s" does not exist.' "${TARGET}" >&2
            continue
        fi

        if [ ! -d "${TARGET}" ]; then
            printf 'Link target "%s" is not a directory.' "${TARGET}" >&2
            continue
        fi

        LINKNAME="${OMADA_HOME}/${TARGET##*/}"

        if [ -e "${LINKNAME}" ]; then
            if [ ! -L "${LINKNAME}" ]; then
                printf 'File "%s" is blocking creation of eponymous symlink.' "${LINKNAME}" >&2
            fi

            continue
        fi

        ln -s "${TARGET}" "${LINKNAME}"
    done
}


if [ ${EUID} -ne 0 ]; then
    echo "You need to be root to run this script." >&2
    exit 1
fi

create_user_directories
create_symlinks
