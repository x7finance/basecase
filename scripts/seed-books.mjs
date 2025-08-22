#!/usr/bin/env node

import { config } from 'dotenv';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import { init, id } from '@instantdb/admin';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Load environment variables
config({ path: join(__dirname, '..', '.env') });

const INSTANT_APP_ID = process.env.INSTANT_APP_ID;
const INSTANT_ADMIN_TOKEN = process.env.INSTANT_ADMIN_TOKEN;
const INSTANT_BASE_URL = process.env.INSTANT_BASE_URL || 'https://api.instantdb.com';

if (!INSTANT_APP_ID || !INSTANT_ADMIN_TOKEN) {
  console.error('Missing INSTANT_APP_ID or INSTANT_ADMIN_TOKEN in environment variables');
  process.exit(1);
}

// Initialize InstantDB admin client
const db = init({
  appId: INSTANT_APP_ID,
  adminToken: INSTANT_ADMIN_TOKEN,
  apiURI: INSTANT_BASE_URL,
  disableValidation: true, // Disable validation for self-hosted
});

// Sample book data
const books = [
  { title: "To Kill a Mockingbird", author: "Harper Lee", isbn: "978-0-06-112008-4", publishedYear: 1960, genre: "Fiction", price: 14.99, inStock: true },
  { title: "1984", author: "George Orwell", isbn: "978-0-452-28423-4", publishedYear: 1949, genre: "Dystopian", price: 13.99, inStock: true },
  { title: "Pride and Prejudice", author: "Jane Austen", isbn: "978-0-14-143951-8", publishedYear: 1813, genre: "Romance", price: 12.99, inStock: false },
  { title: "The Great Gatsby", author: "F. Scott Fitzgerald", isbn: "978-0-7432-7356-5", publishedYear: 1925, genre: "Fiction", price: 10.99, inStock: true },
  { title: "The Catcher in the Rye", author: "J.D. Salinger", isbn: "978-0-316-76948-0", publishedYear: 1951, genre: "Fiction", price: 8.99, inStock: true },
  { title: "Brave New World", author: "Aldous Huxley", isbn: "978-0-06-085052-4", publishedYear: 1932, genre: "Dystopian", price: 14.99, inStock: false },
  { title: "The Hobbit", author: "J.R.R. Tolkien", isbn: "978-0-547-92822-7", publishedYear: 1937, genre: "Fantasy", price: 14.99, inStock: true },
  { title: "Harry Potter and the Sorcerer's Stone", author: "J.K. Rowling", isbn: "978-0-439-70818-8", publishedYear: 1997, genre: "Fantasy", price: 12.99, inStock: true },
  { title: "The Lord of the Rings", author: "J.R.R. Tolkien", isbn: "978-0-544-00341-5", publishedYear: 1954, genre: "Fantasy", price: 29.99, inStock: true },
  { title: "Animal Farm", author: "George Orwell", isbn: "978-0-452-28424-1", publishedYear: 1945, genre: "Political", price: 9.99, inStock: true },
  { title: "Jane Eyre", author: "Charlotte Brontë", isbn: "978-0-14-144114-6", publishedYear: 1847, genre: "Romance", price: 11.99, inStock: false },
  { title: "Wuthering Heights", author: "Emily Brontë", isbn: "978-0-14-143955-6", publishedYear: 1847, genre: "Gothic", price: 10.99, inStock: true },
  { title: "The Odyssey", author: "Homer", isbn: "978-0-14-026886-7", publishedYear: -800, genre: "Epic", price: 13.99, inStock: true },
  { title: "Moby Dick", author: "Herman Melville", isbn: "978-0-14-243724-7", publishedYear: 1851, genre: "Adventure", price: 15.99, inStock: false },
  { title: "War and Peace", author: "Leo Tolstoy", isbn: "978-1-4000-7998-8", publishedYear: 1869, genre: "Historical", price: 19.99, inStock: true }
];

async function seedBooks() {
  console.log('Seeding books data...');
  
  try {
    // Create transactions for all books
    const transactions = books.map(book => {
      const bookId = id();
      return db.tx.books[bookId].update({
        ...book,
        createdAt: new Date().toISOString()
      });
    });

    // Execute all transactions
    await db.transact(transactions);
    
    console.log(`Successfully seeded ${books.length} books`);
    
    // Query to verify
    const result = await db.query({ books: {} });
    console.log(`Verified: ${result.books.length} books in database`);
    
  } catch (error) {
    console.error('Error seeding books:', error);
    process.exit(1);
  }
}

seedBooks();