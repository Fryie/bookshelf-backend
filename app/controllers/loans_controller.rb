class LoansController < ApplicationController
  BookNotAvailableError = Class.new StandardError
  BookNotBorrowedError = Class.new StandardError

  def create
    book_id = params[:book_id]
    book = Book.find(book_id)
    raise BookNotAvailableError if book.status != "available"

    book.update!(status: "borrowed")

    render json: book
  rescue ActiveRecord::RecordNotFound
    render json: {
      code: "book_not_found",
      error: "No such book was found."
    }, status: 404
  rescue BookNotAvailableError
    render json: {
      code: "book_not_available",
      error: "The book is not available currently."
    }, status: 422
  end

  def destroy
    book_id = params[:book_id]
    book = Book.find(book_id)
    raise BookNotBorrowedError if book.status != "borrowed"

    book.update!(status: "available")

    render json: book
  rescue ActiveRecord::RecordNotFound
    render json: {
      code: "book_not_found",
      error: "No such book was found."
    }, status: 404
  rescue BookNotBorrowedError
    render json: {
      code: "book_not_borrowed",
      error: "The book is not borrowed currently."
    }, status: 422
  end
end
