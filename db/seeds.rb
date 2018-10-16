# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
#

Book.create(
  title: "The Passionate Programmer: Creating a Remarkable Career in Software Development",
  author: "Chad Fowler",
  isbn: "978-1934356340",
  image_url: "https://images-na.ssl-images-amazon.com/images/I/51m3yzmDFCL._SX331_BO1,204,203,200_.jpg",
  status: "available",
  physical_location: "Bookshelf at the entrance"
)

Book.create(
  title: "The Pragmatic Programmer. From Journeyman to Master",
  author: "Andrew Hunt, David Thomas, Ward Cunningham",
  isbn: "978-0201616224",
  image_url: "https://images-na.ssl-images-amazon.com/images/I/41BKx1AxQWL._SX396_BO1,204,203,200_.jpg",
  ebook_url: "http://google.com",
  status: "available"
)

Book.create(
  title: "Clean Code: A Handbook of Agile Software Craftsmanship",
  author: "Robert Martin",
  isbn: "978-0132350884",
  image_url: "https://images-na.ssl-images-amazon.com/images/I/515iEcDr1GL._SX385_BO1,204,203,200_.jpg",
  status: "borrowed",
  borrower: "Markus Saehn"
)

Book.create(
  title: "Patterns of Enterprise Application Architecture",
  author: "Martin Fowler",
  isbn: "978-0321127426",
  image_url: "https://images-na.ssl-images-amazon.com/images/I/51IuDvAU1CL._SX387_BO1,204,203,200_.jpg",
  status: "requested"
)
