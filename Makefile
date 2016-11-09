help:
	@echo "make run   # show ttb demo"
	@echo "make clean # remove temporary files"

run:
	echo 'c(calc), c(util), util:start([calc]), calc:inc(1), calc:add(1, 2), util:stop().' | erl

clean:
	rm -f *.beam
	rm -rf ttb_*
