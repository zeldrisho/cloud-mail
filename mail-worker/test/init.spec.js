import { afterEach, describe, expect, it, vi } from 'vitest';
import app from '../src/hono/webs';
import { dbInit } from '../src/init/init';
import settingService from '../src/service/setting-service';

afterEach(() => {
	vi.restoreAllMocks();
});

function createDbStub() {
	return {
		prepare(sql) {
			const statement = {
				sql,
				bind() {
					return statement;
				},
				async run() {
					return {};
				},
				async first() {
					return {};
				},
				async all() {
					return { results: [] };
				}
			};
			return statement;
		},
		async batch() {
			return [];
		}
	};
}

describe('dbInit.v3DB', () => {
	it('creates performance indexes for email polling paths', async () => {
		const preparedSql = [];
		const c = {
			env: {
				db: {
					prepare(sql) {
						preparedSql.push(sql);
						return {
							async run() {
								return {};
							}
						};
					}
				}
			}
		};

		await dbInit.v3DB(c);

		expect(preparedSql).toContain(
			'CREATE INDEX IF NOT EXISTS idx_att_email_type ON attachments(email_id, type);'
		);
		expect(preparedSql).toContain(
			'CREATE INDEX IF NOT EXISTS idx_star_user_email ON star(user_id, email_id);'
		);
		expect(preparedSql).toContain(
			'CREATE INDEX IF NOT EXISTS idx_email_receive_lookup_nocase ON email(to_email COLLATE NOCASE, type, is_del, email_id DESC);'
		);
	});
});

describe('dbInit.init', () => {
	it('accepts init secret from URL path param for compatibility', async () => {
		vi.spyOn(settingService, 'refresh').mockResolvedValue();

		const c = {
			req: {
				header: () => '',
				param: (name) => (name === 'secret' ? 'my-secret' : undefined),
				query: () => undefined
			},
			env: {
				jwt_secret: 'my-secret',
				db: createDbStub()
			},
			set: () => {},
			text: (message) => message
		};

		const result = await dbInit.init(c);
		expect(result).toBe('success');
	});
});

describe('init API route compatibility', () => {
	it('supports GET /init/:secret for manual browser initialization', async () => {
		vi.spyOn(dbInit, 'init').mockImplementation(async (c) => c.text('success'));

		const response = await app.request(
			'http://example.com/init/my-secret',
			{ method: 'GET' },
			{ jwt_secret: 'my-secret' }
		);

		expect(response.status).toBe(200);
		expect(await response.text()).toBe('success');
	});
});
