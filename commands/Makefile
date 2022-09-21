# (org-open-file "~/doc/make/GNU_make.htm")
# (org-open-file "~/doc/make/Эффективное_использование_GNU_make.htm")

include ../misc/make/function.mk

#AT := @
#AT :=

TIMESTAMP   := $(call get_timestamp_str)

COPYFILES   := em-dk1k-tmux-dmenu \
               em-dk1k-xterm \
               em-dk2k-xterm


RSYNC_OPTS  :=$(addprefix --include ,$(COPYFILES)) --exclude '*'
BAK_DST_DIR :=.ATTIC/backup/projects/EM/em-dk/develop/commands
SRC_DIR     :=.
DST_DIR     :=$(HOME)/bin
BAK_LOG     :=$(DST_DIR)/$(BAK_DST_DIR)/$(TIMESTAMP).log


.PHONY: all copy mkdir_bak


all: copy


mkdir_bak:
	$(AT)mkdir -p $(DST_DIR)/$(BAK_DST_DIR)


copy: mkdir_bak
	$(AT)$(call rsync_bak,\
		$(RSYNC_OPTS),\
		$(BAK_DST_DIR),\
		$(TIMESTAMP),\
		$(BAK_LOG),\
		$(SRC_DIR),\
		$(DST_DIR))



#$(error $(addprefix --include ,$(COPYFILES)))

# rsync --include 'em-dk' --include 'Makefile' --exclude '*' --delete --backup --backup-dir="${HOME}/bin/.ATTIC/000.projects.backup/EM_-em-dk/develop/`date \"+%Y%m%d%H%M%S\"`" --log-file="${HOME}/bin/.ATTIC/000.projects.backup/EM_-em-dk/develop/`date \"+%Y%m%d%H%M%S\"`.log" --log-file-format="%o %b %f" -Cavz "./" "${HOME}/bin/test1/"
