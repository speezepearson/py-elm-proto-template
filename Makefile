index.html: src/Main.elm src/Reverse.elm
	elm make src/Main.elm

reverse_pb2.py reverse_pb2.pyi src/Reverse.elm: reverse.proto
	protoc --python_out=. --mypy_out=. --elm_out=src reverse.proto

run: index.html __main__.py
	python .

clean:
	rm -f reverse_pb2.py* src/Reverse.elm index.html
