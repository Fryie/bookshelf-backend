class BooksController < ApplicationController
  AlreadyAvailableError = Class.new StandardError
  InvalidStatusError = Class.new StandardError
  InvalidURLError = Class.new StandardError

  def index
    status_filter = params[:status].presence

    if status_filter
      validate_status!(status_filter)
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
    physical_location = params[:physical_location] || ""
    if params[:ebook_url].present?
      ebook_url = params[:ebook_url]
      validate_url!(ebook_url)
    else
      ebook_url = ""
    end

    book = Book.find(book_id)
    raise AlreadyAvailableError if book.status != "requested"
    book.update!(physical_location: physical_location, ebook_url: ebook_url, status: "available")

    render json: book
  rescue InvalidURLError
    render json: {
      code: "invalid_ebook_url",
      error: "The provided E-Book URL is not valid."
    }, status: 422
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

  def validate_status!(status)
    Book::VALID_STATUS.include?(status) || raise(InvalidStatusError)
  end

  def validate_url!(url)
    url = URI.parse(url)
    url.kind_of?(URI::HTTP) || url.kind_of?(URI::HTTPS) || raise(InvalidURLError)
  rescue
    raise InvalidURLError
  end
end
