import re

def parse_dict_fixed():
    with open('/home/david/BD_teoria/proyecto_final/documentacion/ejemplo_dict_layout.txt', 'r', encoding='utf-8') as f:
        lines = f.readlines()
        
    rows = []
    
    for idx, line in enumerate(lines):
        line = line.rstrip('\n')
        # Skip empty lines, page headers/footers
        if not line.strip():
            continue
        if 'Anexo A' in line or 'Anexos' in line or 'complementan' in line or 'esta documentación' in line or 'plementación' in line:
            continue
        # Skip page number lines
        if re.match(r'^\s*\d+\s*$', line):
            continue
        if '\x0c' in line:
            line = line.replace('\x0c', '')
        if 'Tabla' in line and 'Campo' in line and 'Tipo de dato' in line:
            continue
            
        # Fixed slice parsing
        table = line[0:25].strip()
        field = line[25:44].strip()
        type_val = line[44:58].strip()
        desc = line[58:].strip()
        
        # If it's a row continuation (i.e. table is empty but description or type has text)
        if not table and not field and not type_val and desc:
            if rows:
                rows[-1]['desc'] += ' ' + desc
            continue
            
        # If table name is present but field and type are empty, it might be a wrapped table name
        if table and not field and not type_val:
            rows.append({
                'table': table,
                'field': '',
                'type': '',
                'desc': desc
            })
            continue
            
        # Standard row
        rows.append({
            'table': table,
            'field': field,
            'type': type_val,
            'desc': desc
        })
        
    # Post-process to merge wrapped table names
    merged_rows = []
    i = 0
    while i < len(rows):
        r = rows[i]
        # If this row only has 'table' and 'desc', and the next row has no 'table' but has field and type
        if r['table'] and not r['field'] and not r['type'] and i + 1 < len(rows) and not rows[i+1]['table'] and rows[i+1]['field']:
            next_r = rows[i+1]
            merged_rows.append({
                'table': r['table'],
                'field': next_r['field'],
                'type': next_r['type'],
                'desc': (r['desc'] + ' ' + next_r['desc']).strip()
            })
            i += 2
        else:
            # If table is empty, merge with previous
            if not r['table'] and merged_rows:
                if r['field']:
                    merged_rows[-1]['field'] += ' ' + r['field']
                if r['type']:
                    merged_rows[-1]['type'] += ' ' + r['type']
                if r['desc']:
                    merged_rows[-1]['desc'] += ' ' + r['desc']
            else:
                merged_rows.append(r)
            i += 1
            
    return merged_rows

rows = parse_dict_fixed()
for i, r in enumerate(rows):
    print(f"{i}: {r['table']} | {r['field']} | {r['type']} | {r['desc']}")
