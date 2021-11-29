# Please note: you need to put a tab character \
# at the beginning of every recipe line!
# You can also use \ to transfer a line
# To use this makefile to delete the executable file and \
# all the object files from the directory, type:
# "make clean"
# The target ‘clean’ is not a file, but merely the name of an action
# $@ is the name of the target being generated
# $< is the first предусловие/предпосылка (usually a source file)
# $^ The names of all the prerequisites, with spaces between them

ASM = nasm
ASMFLAGS = -felf64
LD = ld

main: main.o dict.o lib.o
	$(LD) -o $@ $^

main.o: main.asm colon.inc words.inc
	$(ASM) $(ASMFLAGS) $<

%.o: %.asm
	$(ASM) $(ASMFLAGS) $<

.PHONY: clean

clean:
	rm -f *.o main