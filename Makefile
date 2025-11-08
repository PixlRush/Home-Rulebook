.PHONY: all todo clean purge

# All targets for main.texs to make Compiled/*.pdfs
PDF-TARGETS := Compiled/Full.pdf $(shell find . -name "main.tex" | grep -v "\./main\.tex" | sed -E "s/\.?\/?([a-zA-Z0-9]*)(\/.*)*\/main.tex/Compiled\/\1.pdf/")

all: version.tex $(PDF-TARGETS) todo clean

remake: purge all

# Cleaning Up
clean:
	@echo "\n--==Cleaning Up==--\n"
	latexmk -quiet -C
	@if [[ -f main.glo || -f main.gls || -f main.glg ]]; then rm main.gl*; echo 'gloss'; rm main.ist; fi
	@if [ -f ./version.tex ]; then rm ./version.tex; fi

# Purge all
purge:
	@echo "\n--==Purging==--\n"
	latexmk -quiet -C
	rm ./Compiled/*.pdf
	@# Call down to purge voice-lines
	@for MFILE in $(VOICE-TARGETS); do echo "\n-=Purging $$MFILE=-\n"; make -C $${MFILE%/*} purge; done

# Compile Todo List
todo:
	@echo "\n--==Compiling Todo Lists==--\n"	
	@if [ -f todo.txt ]; then rm todo.txt; fi
	@echo "--== TODO ($(shell egrep -Rn --include="*.tex" "^ *% *TODO ?:" | egrep -c ".*")) ==--" >> todo.txt
	@-egrep -Rn --include="*.tex" "^ *% *TODO ?:" >> todo.txt
	@echo "\n--== IN-PROGRESS ($(shell egrep -Rn --include="*.tex" "^ *% *IN[- ]PROGRESS ?:" | egrep -c ".*")) ==--" >> todo.txt
	@-egrep -Rn --include="*.tex" "^ *% *IN[- ]PROGRESS ?:" >> todo.txt
	@echo "\n--== REVIEW ($(shell egrep -Rn --include="*.tex" "^ *% *REVIEW ?:" | egrep -c ".*")) ==--" >> todo.txt
	@-egrep -Rn --include="*.tex" "^ *% *REVIEW ?:" >> todo.txt
	@echo "\n--== DONE ($(shell egrep -Rn --include="*.tex" "^ *% *DONE ?:" | egrep -c ".*")) ==--" >> todo.txt
	@-egrep -Rn --include="*.tex" "^ *% *DONE ?:" >> todo.txt
	@echo "Done"

version.tex:
	@./versioning.sh > version.tex

# Compiled PDF creation
Compiled/Full.pdf: main.tex comp.tex preamble.tex title.tex $(shell find . -name "*.tex") Resources/*/*.tex
	@echo "\n--==Compiling $@==--\n"
	latexmk -f -xelatex -interaction=nonstopmode -quiet --shell-escape -synctex=1 $<
	if [[ -f main.glo || -f main.gls || -f main.glg ]]; then makeglossaries main && \
	latexmk -f -xelatex -interaction=nonstopmode -quiet --shell-escape -synctex=1 $<; \
	rm main.gl*; echo 'gloss'; rm main.ist; fi
	mv main.pdf $@

# Generalized PDF Creation
Compiled/%.pdf: %/main.tex %/comp.tex preamble.tex title.tex %/*.tex %/*/*.tex %/*/*/*.tex Resources/*/*.tex
	@echo "\n--==Compiling $@==--\n"
	latexmk -f -xelatex -interaction=nonstopmode -quiet -synctex=1 $<
	if [[ -f main.glo || -f main.gls || -f main.glg ]]; then makeglossaries main && \
	latexmk -f -xelatex -interaction=nonstopmode -quiet --shell-escape -synctex=1 $<; \
	rm main.gl*; echo 'gloss'; rm main.ist; fi
	mv main.pdf $@
