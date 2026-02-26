export function getTextWidth(text, font = '14px sans-serif') {
    // Force canvas resolution
    const canvas = document.createElement('canvas');
    canvas.width = 2000; // large enough canvas
    canvas.style.width = '1000px'; // avoid CSS scaling effects
    const ctx = canvas.getContext('2d');
    ctx.font = font;
    return ctx.measureText(text).width;
}