.PHONY: sphinx


.PHONY: html
html:
	make -C sphinx html


.PHONY: pdf
pdf:
	make -C sphinx latexpdf
