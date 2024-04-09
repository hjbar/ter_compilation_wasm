default: clean fmt build clear

build:
	dune build

clean:
	dune clean
	rm -f test/*.wat
	rm -f test/*.wast

fmt:
	dune fmt

clear:
	clear

mrproper: clean
