import { parseHTML } from 'linkedom';

const BLOCK_TAGS = new Set([
	'script',
	'iframe',
	'object',
	'embed',
	'form',
	'link',
	'meta',
	'base'
]);

const URL_ATTRS = new Set(['href', 'src', 'xlink:href', 'action', 'formaction', 'poster']);
const DROP_ATTRS = new Set(['srcdoc']);

function isUnsafeUrl(value = '') {
	const lower = String(value).trim().toLowerCase();
	return lower.startsWith('javascript:') || lower.startsWith('vbscript:') || lower.startsWith('data:text/html');
}

function sanitizeStyle(value = '') {
	const lower = String(value).toLowerCase();
	if (lower.includes('expression(') || lower.includes('javascript:') || lower.includes('@import')) {
		return '';
	}
	return value;
}

const htmlSanitizeUtils = {
	sanitizeHtml(html = '') {
		const { document } = parseHTML(String(html));

		document.querySelectorAll('*').forEach((node) => {
			const tag = node.tagName?.toLowerCase();
			if (tag && BLOCK_TAGS.has(tag)) {
				node.remove();
				return;
			}

			for (const attr of [...node.attributes]) {
				const name = attr.name.toLowerCase();
				const value = attr.value;

				if (name.startsWith('on') || DROP_ATTRS.has(name)) {
					node.removeAttribute(attr.name);
					continue;
				}

				if (name === 'style') {
					const safeStyle = sanitizeStyle(value);
					if (!safeStyle) {
						node.removeAttribute(attr.name);
					} else {
						node.setAttribute(attr.name, safeStyle);
					}
					continue;
				}

				if (URL_ATTRS.has(name) && isUnsafeUrl(value)) {
					node.removeAttribute(attr.name);
				}
			}
		});

		return document.toString();
	}
};

export default htmlSanitizeUtils;
