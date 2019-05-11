SHELL=bash


deps=$(shell ls -1 setup*.jl environments/*/*.toml)
logs=$(shell ls -1 *.jl | sed -e '/setup.*/d' -e 's/\.jl$$/.log/')


all: $(logs)

clean:
	-rm $(logs)


%.log: %.jl $(deps)
	julia --color=no $< 2>&1 | tee $@
#	sed -i '1s/^\(\xef\xbb\xbf\)\?/\xef\xbb\xbf/' $@
	git diff --stat $@


.PHONY: all clean

.SUFFIXES:
