<template>
  <div class="content-box" ref="contentBox">
    <div ref="container" class="content-html"></div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'

const props = defineProps({
  html: {
    type: String,
    required: true
  }
})

const container = ref(null)
const contentBox = ref(null)
let shadowRoot = null

const BLOCK_TAGS = new Set(['script', 'iframe', 'object', 'embed', 'link', 'meta', 'base', 'form'])
const URL_ATTRS = new Set(['href', 'src', 'xlink:href', 'action', 'formaction', 'poster'])

function isUnsafeUrl(value = '') {
  const lower = String(value).trim().toLowerCase()
  return lower.startsWith('javascript:') || lower.startsWith('vbscript:') || lower.startsWith('data:text/html')
}

function sanitizeInlineStyle(value = '') {
  const lower = String(value).toLowerCase()
  if (lower.includes('expression(') || lower.includes('javascript:') || lower.includes('@import')) {
    return ''
  }
  return value
}

function sanitizeHtmlAndBodyStyle(rawHtml = '') {
  const parser = new DOMParser()
  const doc = parser.parseFromString(String(rawHtml), 'text/html')
  const bodyStyle = sanitizeInlineStyle(doc.body?.getAttribute('style') || '')

  doc.querySelectorAll('*').forEach(node => {
    const tag = node.tagName?.toLowerCase()
    if (BLOCK_TAGS.has(tag)) {
      node.remove()
      return
    }

    Array.from(node.attributes).forEach(attr => {
      const name = attr.name.toLowerCase()
      const value = attr.value || ''

      if (name.startsWith('on') || name === 'srcdoc') {
        node.removeAttribute(attr.name)
        return
      }

      if (name === 'style') {
        const safeStyle = sanitizeInlineStyle(value)
        if (!safeStyle) {
          node.removeAttribute(attr.name)
        } else {
          node.setAttribute(attr.name, safeStyle)
        }
        return
      }

      if (URL_ATTRS.has(name) && isUnsafeUrl(value)) {
        node.removeAttribute(attr.name)
      }
    })
  })

  return {
    html: doc.body?.innerHTML || '',
    bodyStyle
  }
}

function updateContent() {
  if (!shadowRoot) return;

  const { html, bodyStyle } = sanitizeHtmlAndBodyStyle(props.html)

  shadowRoot.innerHTML = `
    <style>
      :host {
        all: initial;
        width: 100%;
        height: 100%;
        font-family: -apple-system, Inter, BlinkMacSystemFont,
                    'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
        font-size: 14px;
        line-height: 1.5;
        color: #13181D;
        word-break: break-word;
      }

      h1, h2, h3, h4 {
          font-size: 18px;
          font-weight: 700;
      }

      p {
        margin: 0;
      }

      a {
        text-decoration: none;
        color: #0E70DF;
      }

      .shadow-content {
        background: #FFFFFF;
        width: fit-content;
        height: fit-content;
        min-width: 100%;
      }

      img:not(table img) {
        max-width: 100%;
        height: auto !important;
      }

    </style>
    <div class="shadow-content">
      ${html}
    </div>
  `;

  if (bodyStyle) {
    const shadowContent = shadowRoot.querySelector('.shadow-content')
    shadowContent?.setAttribute('style', bodyStyle)
  }
}

function autoScale() {
  if (!shadowRoot || !contentBox.value) return

  const parent = contentBox.value
  const shadowContent = shadowRoot.querySelector('.shadow-content')

  if (!shadowContent) return

  const parentWidth = parent.offsetWidth
  const childWidth = shadowContent.scrollWidth

  if (childWidth === 0) return

  const scale = parentWidth / childWidth

  const hostElement = shadowRoot.host
  hostElement.style.zoom = scale
}

onMounted(() => {
  shadowRoot = container.value.attachShadow({ mode: 'open' })
  updateContent()
  autoScale()
})

watch(() => props.html, () => {
  updateContent()
  autoScale()
})
</script>

<style scoped>
.content-box {
  width: 100%;
  height: 100%;
  overflow: hidden;
  font-family: -apple-system, Inter, BlinkMacSystemFont, "Segoe UI", "Noto Sans", Helvetica, Arial, sans-serif, "Apple Color Emoji", "Segoe UI Emoji";
}

.content-html {
  width: 100%;
  height: 100%;
}
</style>
