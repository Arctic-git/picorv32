#!/usr/bin/env python3

import argparse

def append_bin_file(source1_file_path, source2_file_path, destination_file_path, offset):
    with open(source1_file_path, 'rb') as f:
        source_data1 = f.read()

    with open(source2_file_path, 'rb') as f:
        source_data2 = f.read()

    with open(destination_file_path, 'wb') as f:
        f.write(source_data1)
        f.seek(offset)
        f.write(source_data2)

def main():
    parser = argparse.ArgumentParser(description='Append the contents of a binary file to another at a specified offset.')
    parser.add_argument('source1', help='Path to the source1 binary file')
    parser.add_argument('source2', help='Path to the source2 binary file')
    parser.add_argument('destination', help='Path to the destination binary file')
    parser.add_argument('offset', type=int, help='Offset in bytes where the source2 file should be appended to source1')

    args = parser.parse_args()
    append_bin_file(args.source1, args.source2, args.destination, args.offset)

if __name__ == '__main__':
    main()