from PIL import Image

def remove_white(image_path):
    img = Image.open(image_path).convert("RGBA")
    datas = img.getdata()

    newData = []
    for item in datas:
        if item[0] > 240 and item[1] > 240 and item[2] > 240:
            newData.append((255, 255, 255, 0))
        else:
            newData.append(item)

    img.putdata(newData)
    img.save(image_path, "PNG")

remove_white(r"C:\Users\yusf2000.runnervmxu3fp\.gemini\antigravity\scratch\yousfkarim2001\assets\images\islamic_frame.png")
print("Fixed islamic_frame.png")
