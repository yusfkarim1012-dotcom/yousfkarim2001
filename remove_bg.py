from rembg import remove
from PIL import Image

files = [
    "assets/images/prayer_times_icon.png", 
    "assets/images/hijri_calendar_icon.png"
]

for filename in files:
    print(f"Processing {filename}...")
    try:
        img = Image.open(filename)
        out = remove(img)
        out.save(filename)
        print(f"Success: {filename}")
    except Exception as e:
        print(f"Error: {e}")
