#!/usr/bin/env python3
"""Merge multiple structured XML card files into a single valid deck XML.

Usage: tools/merge_cards.py <cards_dir> [<cards_dir> ...] <output.xml>
If output omitted, writes to merged-cards.xml in CWD.

This script accepts one or more source directories. Files are merged
in the given order which allows merging a base set followed by one 
or more DLC directories so DLC elements override or append based on ID.
"""
import sys
import os
from xml.etree import ElementTree as ET


def merge(cards_dirs, out_path):
    if isinstance(cards_dirs, (str,)):
        cards_dirs = [cards_dirs]

    files = []
    for cards_dir in cards_dirs:
        if not os.path.isdir(cards_dir):
            continue
        dir_files = sorted(
            [os.path.join(cards_dir, f) for f in os.listdir(cards_dir) if f.endswith('.xml')]
        )
        files.extend(dir_files)

    if not files:
        raise SystemExit('No XML files found in %s' % (', '.join(cards_dirs)))

    first = True
    root = ET.Element('cards')
    
    # Dictionaries used to prevent duplicates and handle DLC overrides cleanly
    atoms_dict = {}
    molecules_dict = {}

    for fn in files:
        try:
            tree = ET.parse(fn)
        except ET.ParseError as e:
            raise SystemExit('Failed to parse %s: %s' % (fn, e))
        src = tree.getroot()
        
        # Inherit global attributes like game name or version from first file
        if first:
            for attr in ('game', 'version'):
                if attr in src.attrib:
                    root.set(attr, src.attrib[attr])
            first = False

        # Extract and map all atoms to the dictionary using ID as key
        atoms_node = src.find('atoms')
        if atoms_node is not None:
            for atom in atoms_node.findall('atom'):
                atom_id = atom.attrib.get('id')
                if atom_id:
                    atoms_dict[atom_id] = atom

        # Extract and map all molecules to the dictionary using ID as key
        molecules_node = src.find('molecules')
        if molecules_node is not None:
            for molecule in molecules_node.findall('molecule'):
                mol_id = molecule.attrib.get('id')
                if mol_id:
                    molecules_dict[mol_id] = molecule

    # Build the final XML tree array blocks according to the new XSD layout
    if atoms_dict:
        atoms_root = ET.SubElement(root, 'atoms')
        # Sorting by key guarantees deterministic output on every build
        for atom_id in sorted(atoms_dict.keys()):
            atoms_root.append(atoms_dict[atom_id])

    if molecules_dict:
        molecules_root = ET.SubElement(root, 'molecules')
        for mol_id in sorted(molecules_dict.keys()):
            molecules_root.append(molecules_dict[mol_id])

    # Inject the canonical validation schema location attributes
    root.set('xmlns:xsi', 'http://www.w3.org/2001/XMLSchema-instance')
    root.set('xsi:noNamespaceSchemaLocation', 'cards.xsd')

    tree = ET.ElementTree(root)
    ET.indent(tree, space='  ')

    # Verify and create output directory structure if required
    out_dir = os.path.dirname(out_path)
    if out_dir:
        os.makedirs(out_dir, exist_ok=True)
        
    tree.write(out_path, encoding='utf-8', xml_declaration=True)


def main(argv):
    if len(argv) < 2:
        print(__doc__)
        return 2
    src_dirs = argv[:-1]
    out_path = argv[-1]
    merge(src_dirs, out_path)
    print('Wrote', out_path)


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))