class LoansController < ApplicationController
  NoBorrowerError = Class.new StandardError
  BookNotAvailableError = Class.new StandardError
  BookNotBorrowedError = Class.new StandardError

  def create
    book_id = params[:book_id]
    borrower = params[:borrower].presence || raise(NoBorrowerError)

    book = Book.find(book_id)
    raise BookNotAvailableError if book.status != "available"

    book.update!(status: "borrowed", borrower: borrower)

    render json: book
  rescue NoBorrowerError
    render json: {
      code: "no_borrower",
      error: "Need to provide a borrower for borrowing a book."
    }, status: 422
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

    book.update!(status: "available", borrower: "")

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
