#!/usr/bin/env python3
import argparse
import markdown
import os

if __name__ == '__main__':
	parser = argparse.ArgumentParser(description='Markdown to HTML implemented by self to minimize potentially malicious code being installed on machine.')
	parser.add_argument('input_file', help='the tracefile to remove the coverage data from')
	parser.add_argument('-output_file', help='filename for the output to be written to', required=False)
	args = parser.parse_args()
	if args.output_file is None:
		args.output_file = os.path.splitext(os.path.basename(args.input_file))[0] + ".html"

	with open(args.input_file, "r", encoding="utf-8") as input_file:
		text = input_file.read()

	html = markdown.markdown(text)

	with open(args.output_file, "w", encoding="utf-8", errors="xmlcharrefreplace") as output_file:
		output_file.write(html)
