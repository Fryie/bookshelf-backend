class BooksController < ApplicationController
  InvalidStatusError = Class.new StandardError

  def index
    status_filter = params[:status].presence || "available"
    validate_status(status_filter) || raise(InvalidStatusError)

    books = Book.where(status: status_filter)

    render json: books.to_json
  rescue InvalidStatusError
    render json: {
      code: "invalid_status_filter",
      error: "The specified status filter is invalid. Please use one of #{Book::VALID_STATUS.join(", ")}."
    }, status: 422
  end

  private

  def validate_status(status)
    Book::VALID_STATUS.include?(status)
  end
end
