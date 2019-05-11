SHELL=bash


logs=$(shell ls -1 *.jl | sed -e '/setup-.*/d' -e 's/\.jl$$/.log/')


all: $(logs)

clean:
	-rm $(logs)


%.log: %.jl
	julia --color=no $< 2>&1 | tee $@
#	sed -i '1s/^\(\xef\xbb\xbf\)\?/\xef\xbb\xbf/' $@


.PHONY: all

.SUFFIXES:
