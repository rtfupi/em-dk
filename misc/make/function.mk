##.###########################################################################.
##! Copyright (C) Марков Евгений 2022
##!
##! \file   function.mk
##! \author Марков Евгений <mark@gitlab.utis.lan>
##! \date   2022-09-20 22:36
##!
##! \brief  Библиотека ф-ий.
##|
##'###########################################################################'

# (evm-org-open-file "~/doc/make/GNU_make.htm")

# $(warning "---> function.mk")


comma := ,
null  :=
space := $(null) #


DEVNULL := /dev/null 2>&1



##.=======================================================================.
##! \def get_timestamp_str
##! \brief Ф-ия создание timestamp как строки формата %Y%m%d%H%M%S.
##!
##! \return - timestamp как строка.
##|
##'======================================================================='
get_timestamp_str = $(shell date "+%Y%m%d%H%M%S")



##.===========================================================================.
##! \def rsync_bak
##! \brief Rsync with increment backup.
##!
##! Example:
##!
##! ~/projects/em-dk/develop         ${HOME}/bin
##! +-- dirs or files          ==>   +-- dirs or files
##!     +-- ...                          +-- ...
##!     +-- Makefile                     |
##!                                      +-- .ATTIC/.backup/em-dk/develop
##!                                          +-- inc_dir1
##!                                          |   +-- bak dirs or files
##!                                          |   +-- ...
##!                                          +-- inc_dirN
##!                                          |   +-- bak dirs or files
##!                                          |   +-- ...
##!                                          +-- xxxx1.log
##!                                          +-- ...
##!                                          +-- xxxxN.log
##!
##!  $1 - --include 'file1' ... --include 'fileN --exclude '*'
##!  $2 - .ATTIC/.backup/em-dk/develop
##!  $3 - xxxxN
##!  $4 - .ATTIC/.backup/em-dk/develop/xxxxN.log
##!  $5 - .
##!  $6 - $(HOME)/bin
##!
##! \param[in] $1 - a additional rsync options;
##! \param[in] $2 - relative path to destination backup diretory;
##! \param[in] $3 - a name of increment backup diretory;
##! \param[in] $4 - path to logfile;
##! \param[in] $5 - path to source diretory;
##! \param[in] $6 - path to destination diretory.
##|
##'==========================================================================='
define rsync_bak
fn() { \
    rsync $(strip $(1)) \
          --backup --backup-dir="$(strip $(2))/$(strip $(3))" \
          --log-file="$(strip $(4))" --log-file-format="%o %b %f" \
          -Cavz "$(strip $(5))/" "$(strip $(6))/"; \
    }; export -f fn; sh -i -c fn
endef



# $(warning "<--- function.mk")
