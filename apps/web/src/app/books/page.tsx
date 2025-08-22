'use client';

import { useState, useEffect } from 'react';
import { db } from '@basecase/database';
import { id } from '@instantdb/react';

// Sample book data
const sampleBooks = [
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

export default function BooksPage() {
  const [isSeeding, setIsSeeding] = useState(false);
  const [seedMessage, setSeedMessage] = useState('');
  
  // Query books from InstantDB
  const { data, isLoading, error } = db.useQuery({ books: {} });

  const seedBooks = async () => {
    setIsSeeding(true);
    setSeedMessage('Seeding books...');
    
    try {
      // Add each book to the database
      for (const book of sampleBooks) {
        const bookId = id();
        await db.transact([
          db.tx.books[bookId].update({
            ...book,
            createdAt: new Date()
          })
        ]);
      }
      
      setSeedMessage(`Successfully seeded ${sampleBooks.length} books!`);
    } catch (error) {
      console.error('Error seeding books:', error);
      setSeedMessage(`Error: ${error.message}`);
    } finally {
      setIsSeeding(false);
    }
  };

  if (error) {
    return (
      <div className="container mx-auto p-8">
        <h1 className="text-3xl font-bold mb-6">Books Test Page</h1>
        <div className="bg-red-50 border border-red-200 rounded-lg p-4">
          <p className="text-red-800">Error loading books: {error.message}</p>
        </div>
      </div>
    );
  }

  return (
    <div className="container mx-auto p-8">
      <h1 className="text-3xl font-bold mb-6">Books Test Page</h1>
      
      <div className="mb-6">
        <button
          onClick={seedBooks}
          disabled={isSeeding}
          className="bg-blue-500 hover:bg-blue-600 text-white font-medium py-2 px-4 rounded disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {isSeeding ? 'Seeding...' : 'Seed Sample Books'}
        </button>
        {seedMessage && (
          <p className={`mt-2 ${seedMessage.includes('Error') ? 'text-red-600' : 'text-green-600'}`}>
            {seedMessage}
          </p>
        )}
      </div>

      <div className="bg-white shadow rounded-lg p-6">
        <h2 className="text-xl font-semibold mb-4">
          InstantDB Connection Status
        </h2>
        
        <div className="space-y-2 mb-6">
          <p>
            <span className="font-medium">Status:</span>{' '}
            <span className={isLoading ? 'text-yellow-600' : 'text-green-600'}>
              {isLoading ? 'Loading...' : 'Connected'}
            </span>
          </p>
          <p>
            <span className="font-medium">Books Found:</span>{' '}
            {data?.books?.length || 0}
          </p>
        </div>

        {data?.books && data.books.length > 0 && (
          <div>
            <h3 className="text-lg font-medium mb-3">Books in Database:</h3>
            <div className="overflow-x-auto">
              <table className="min-w-full divide-y divide-gray-200">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Title</th>
                    <th className="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Author</th>
                    <th className="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Genre</th>
                    <th className="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Year</th>
                    <th className="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Price</th>
                    <th className="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Stock</th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {data.books.map((book) => (
                    <tr key={book.id}>
                      <td className="px-4 py-2 text-sm">{book.title}</td>
                      <td className="px-4 py-2 text-sm">{book.author}</td>
                      <td className="px-4 py-2 text-sm">{book.genre}</td>
                      <td className="px-4 py-2 text-sm">{book.publishedYear}</td>
                      <td className="px-4 py-2 text-sm">${book.price}</td>
                      <td className="px-4 py-2 text-sm">
                        <span className={book.inStock ? 'text-green-600' : 'text-red-600'}>
                          {book.inStock ? 'In Stock' : 'Out of Stock'}
                        </span>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        )}

        {(!data?.books || data.books.length === 0) && !isLoading && (
          <p className="text-gray-500">
            No books found. Click "Seed Sample Books" to add test data.
          </p>
        )}
      </div>
    </div>
  );
}