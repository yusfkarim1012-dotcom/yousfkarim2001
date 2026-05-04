from rembg import remove
from PIL import Image
import os

files = {
    'fajr_icon': r'C:\Users\yusf2000.runnervmxu3fp\.gemini\antigravity\brain\4820bc14-56dc-4881-a7a5-48bc9d0cf760\fajr_icon_1777853342848.png',
    'sunrise_icon': r'C:\Users\yusf2000.runnervmxu3fp\.gemini\antigravity\brain\4820bc14-56dc-4881-a7a5-48bc9d0cf760\sunrise_icon_1777853354968.png',
    'dhuhr_icon': r'C:\Users\yusf2000.runnervmxu3fp\.gemini\antigravity\brain\4820bc14-56dc-4881-a7a5-48bc9d0cf760\dhuhr_icon_1777853367859.png',
    'asr_icon': r'C:\Users\yusf2000.runnervmxu3fp\.gemini\antigravity\brain\4820bc14-56dc-4881-a7a5-48bc9d0cf760\asr_icon_1777853386367.png',
    'maghrib_icon': r'C:\Users\yusf2000.runnervmxu3fp\.gemini\antigravity\brain\4820bc14-56dc-4881-a7a5-48bc9d0cf760\maghrib_icon_1777853397458.png',
    'isha_icon': r'C:\Users\yusf2000.runnervmxu3fp\.gemini\antigravity\brain\4820bc14-56dc-4881-a7a5-48bc9d0cf760\isha_icon_1777853410944.png',
    'islamic_frame': r'C:\Users\yusf2000.runnervmxu3fp\.gemini\antigravity\brain\4820bc14-56dc-4881-a7a5-48bc9d0cf760\islamic_frame_1777853430034.png'
}

dest_dir = r'C:\Users\yusf2000.runnervmxu3fp\.gemini\antigravity\scratch\yousfkarim2001\assets\images'

for name, path in files.items():
    print(f"Processing {name}...")
    img = Image.open(path)
    out = remove(img)
    if name != 'islamic_frame':
        bbox = out.getbbox()
        if bbox:
            out = out.crop(bbox)
    
    out_path = os.path.join(dest_dir, f"{name}.png")
    out.save(out_path)
    print(f"Saved {out_path}")

print("Done!")
