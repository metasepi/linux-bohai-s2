PROGS = src/ustat

$(PROGS): %: %.c
	gcc -o $@ $<

test: $(PROGS)
	$(foreach prog, $(PROGS), $(prog))

clean:
	rm -f $(PROGS)
