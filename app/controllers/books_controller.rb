class BooksController < ApplicationController
  AlreadyAvailableError = Class.new StandardError
  InvalidStatusError = Class.new StandardError

  def index
    status_filter = params[:status].presence

    if status_filter
      validate_status(status_filter) || raise(InvalidStatusError)
      books = Book.where(status: status_filter)
    else
      books = Book.all
    end

    render json: books.to_json
  rescue InvalidStatusError
    render json: {
      code: "invalid_status_filter",
      error: "The specified status filter is invalid. Please use one of #{Book::VALID_STATUS.join(", ")}."
    }, status: 422
  end

  def create
    book_id = params[:book_request_id]

    book = Book.find(book_id)
    raise AlreadyAvailableError if book.status != "requested"
    book.update!(status: "available")

    render json: book
  rescue ActiveRecord::RecordNotFound
    render json: {
      code: "book_not_found",
      error: "No book with that ID has been requested."
    }, status: 404
  rescue AlreadyAvailableError
    render json: {
      code: "already_available",
      error: "This book is already available (or borrowed)."
    }, status: 422
  end

  private

  def validate_status(status)
    Book::VALID_STATUS.include?(status)
  end
end
