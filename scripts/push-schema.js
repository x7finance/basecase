#!/usr/bin/env node

const schema = require('../packages/database/src/schema.ts').default;

// Convert the schema to InstantDB's expected format
const entities = {};
const links = {};

// Extract entities from schema
for (const [entityName, entityDef] of Object.entries(schema.entities)) {
  const attrs = {};
  
  // Extract attributes from entity definition
  if (entityDef && typeof entityDef === 'object') {
    const entityConfig = entityDef.config || entityDef;
    if (entityConfig.attrs) {
      for (const [attrName, attrDef] of Object.entries(entityConfig.attrs)) {
        // Convert attribute definition to InstantDB format
        attrs[attrName] = {};
        if (attrDef.config) {
          if (attrDef.config.type) attrs[attrName].type = attrDef.config.type;
          if (attrDef.config.unique) attrs[attrName].unique = true;
          if (attrDef.config.indexed) attrs[attrName].indexed = true;
          if (attrDef.config.optional) attrs[attrName].optional = true;
        }
      }
    }
  }
  
  entities[entityName] = attrs;
}

// Extract links from schema
if (schema.links) {
  Object.assign(links, schema.links);
}

console.log('Schema to push:');
console.log(JSON.stringify({ entities, links }, null, 2));

// Since InstantDB's local instance doesn't have a direct schema push endpoint,
// we'll output the schema for manual application
console.log('\nNote: The local InstantDB instance may need to be configured to accept this schema.');
console.log('The schema has been defined in the TypeScript code and will be validated at runtime.');