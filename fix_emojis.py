filepath = r"c:\Users\HP\PlantDiseaseApp\plant_disease_app\lib\pages\home_page.dart"

with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# Strategy: find mojibake sequences and decode them properly
# The broken emojis are UTF-8 bytes that were read as CP1252, then saved as UTF-8
# To fix: encode the broken text back to CP1252 bytes, then decode those bytes as UTF-8

def fix_mojibake(text):
    """Fix double-encoded UTF-8 text (UTF-8 -> CP1252 -> UTF-8)"""
    result = []
    i = 0
    while i < len(text):
        # Check if current char could be start of mojibake sequence
        # Mojibake from 4-byte UTF-8 emojis typically starts with characters
        # that have high codepoints when the UTF-8 bytes are misread as CP1252
        ch = text[i]
        
        if ord(ch) > 127:
            # Try to collect a mojibake sequence and decode it
            # Try different lengths (4-byte emoji = up to ~8 mojibake chars)
            found = False
            for length in range(12, 1, -1):
                if i + length > len(text):
                    continue
                candidate = text[i:i+length]
                try:
                    # Encode back to CP1252 bytes
                    raw_bytes = candidate.encode('cp1252')
                    # Try to decode as UTF-8
                    decoded = raw_bytes.decode('utf-8')
                    # Verify it produces valid characters (emojis, etc)
                    if all(ord(c) > 127 or c.isascii() for c in decoded):
                        result.append(decoded)
                        i += length
                        found = True
                        break
                except (UnicodeEncodeError, UnicodeDecodeError):
                    continue
            
            if not found:
                result.append(ch)
                i += 1
        else:
            result.append(ch)
            i += 1
    
    return ''.join(result)

fixed_content = fix_mojibake(content)

changes = sum(1 for a, b in zip(content, fixed_content) if a != b)
print(f"Characters changed: {changes}")
print(f"Original length: {len(content)}")
print(f"Fixed length: {len(fixed_content)}")

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(fixed_content)

print("File saved successfully!")
