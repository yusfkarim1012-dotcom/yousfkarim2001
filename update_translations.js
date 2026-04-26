const fs = require('fs');
const path = require('path');

const translations = {
  'ku.json': { "small": "بچووک", "medium": "مامناوەند", "large": "گەورە", "overlay_size": "قەبارەی مسبحەی دەرەوە" },
  'ar.json': { "small": "صغير", "medium": "متوسط", "large": "كبير", "overlay_size": "حجم المسبحة الخارجية" },
  'en.json': { "small": "Small", "medium": "Medium", "large": "Large", "overlay_size": "Overlay Tasbih Size" },
  'de.json': { "small": "Klein", "medium": "Mittel", "large": "Groß", "overlay_size": "Overlay-Tasbih-Größe" },
  'ms.json': { "small": "Kecil", "medium": "Sederhana", "large": "Besar", "overlay_size": "Saiz Tasbih Overlay" },
  'tr.json': { "small": "Küçük", "medium": "Orta", "large": "Büyük", "overlay_size": "Yüzen Tesbih Boyutu" },
  'pt.json': { "small": "Pequeno", "medium": "Médio", "large": "Grande", "overlay_size": "Tamanho do Tasbih Flutuante" },
  'ru.json': { "small": "Маленький", "medium": "Средний", "large": "Большой", "overlay_size": "Размер плавающего тасбиха" },
  'jp.json': { "small": "小さい", "medium": "中", "large": "大きい", "overlay_size": "フローティングタスビのサイズ" },
  'am.json': { "small": "ትንሽ", "medium": "መካከለኛ", "large": "ትልቅ", "overlay_size": "ተንሳፋፊ ታስቢህ መጠን" }
};

const dir = 'C:\\Users\\yusf2000.runnervmxu3fp\\.gemini\\antigravity\\scratch\\yousfkarim2001\\assets\\translations';

for (const [file, trans] of Object.entries(translations)) {
  const filePath = path.join(dir, file);
  if (fs.existsSync(filePath)) {
    let raw = fs.readFileSync(filePath, 'utf8');
    // Remove BOM if present
    if (raw.charCodeAt(0) === 0xFEFF) {
      raw = raw.slice(1);
    }
    let data = JSON.parse(raw);
    data = { ...data, ...trans };
    fs.writeFileSync(filePath, JSON.stringify(data, null, 2), 'utf8');
    console.log('Updated ' + file);
  }
}
