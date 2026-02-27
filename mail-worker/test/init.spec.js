import { describe, it, expect } from 'vitest';
import { dbInit } from '../src/init/init';

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
