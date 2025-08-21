// This file is kept at the root for instant-cli compatibility
// The actual schema is in packages/database/src/schema.ts
// biome-ignore lint/style/noExportedImports: no idea why this is needed
import schema from './packages/database/src/schema';

export type { AppSchema } from './packages/database/src/schema';
export default schema;
