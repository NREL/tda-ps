SHELL=bash


TIME=`which time` --verbose


deps=$(shell ls -1 setup*.jl environments/*/*.toml)
logs=$(shell ls -1 *.jl | sed -e '/setup.*/d' -e 's/\.jl$$/.log/')
maps=$(shell find ../contingency-datasets -name \*.dot | sed -e 's/.dot$$/.svg/')


all: logs maps

clean:
	-rm $(logs) $(maps)


logs: $(logs)


%.log: %.jl $(deps)
	$(TIME) julia --color=no $< 2>&1 | tee $@
#	sed -i '1s/^\(\xef\xbb\xbf\)\?/\xef\xbb\xbf/' $@
	-git diff --stat $@


maps: $(maps)

%.svg: %.dot
	-sfdp -T svg -o $@ $<


.PHONY: all clean logs maps

.SUFFIXES:
