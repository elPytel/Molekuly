#!/usr/bin/env python3
import os
import sys
import xml.etree.ElementTree as ET

try:
    from rdkit import Chem
    from rdkit.Chem import Draw
except ImportError:
    print("Error: rdkit package is required. Please run 'pip install rdkit'")
    sys.exit(1)

def generate_missing_images(merged_xml_path):
    if not os.path.exists(merged_xml_path):
        print(f"Error: Merged XML not found at {merged_xml_path}")
        return

    tree = ET.parse(merged_xml_path)
    root = tree.getroot()
    
    molecules_node = root.find('molecules')
    if molecules_node is None:
        return

    for molecule in molecules_node.findall('molecule'):
        title = molecule.find('title').text
        image_path = molecule.find('image').text
        smiles_node = molecule.find('smiles')
        
        if smiles_node is None or not smiles_node.text:
            continue
            
        smiles_str = smiles_node.text.strip()
        
        # Check if image already exists to guarantee it acts as a fallback/cache
        if os.path.exists(image_path):
            continue
            
        print(f"Generating missing structure for: {title} -> {image_path}")
        
        # Ensure target assets subfolder exists
        os.makedirs(os.path.dirname(image_path), exist_ok=True)
        
        try:
            mol = Chem.MolFromSmiles(smiles_str)
            if mol is None:
                print(f"  Error: Invalid SMILES syntax for {title}: {smiles_str}")
                continue
            
            # Render high quality transparent PNG with optimized padding
            Draw.MolToFile(mol, image_path, size=(400, 400))
        except Exception as e:
            print(f"  Failed to render {title}: {e}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: generate_molecules.py <cards_merged.xml>")
        sys.exit(1)
    generate_missing_images(sys.argv[1])