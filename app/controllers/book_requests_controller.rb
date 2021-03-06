class BookRequestsController < ApplicationController
  BookExistsError = Class.new StandardError

  def create
    isbn = ISBNService.validate_and_convert_isbn(params["isbn"])

    raise BookExistsError if Book.exists?(isbn: isbn)

    book_attributes = ISBNService.lookup(isbn)
    book = Book.create!(
      book_attributes.merge(status: "requested")
    )

    render json: book
  rescue BookExistsError
    render json: {
      code: "book_exists",
      error: "Book has already been requested"
    }, status: 409
  rescue ISBNService::BookNotFoundError
    render json: {
      code: "book_not_found",
      error: "Could not find information for ISBN #{params["isbn"]}"
    }, status: 404
  rescue ISBNService::InvalidApiResponseError
    render json: {
      code: "invalid_downstream_api_response",
      error: "Downstream API fucked up"
    }, status: 500
  rescue ISBNService::InvalidISBNError
    render json: {
      code: "invalid_isbn_error",
      error: "Invalid ISBN"
    }, status: 422
  end

  private

  BASE_URL = "https://openlibrary.org"
  ISBN_LOOKUP_URL = "#{BASE_URL}/api/books?bibkeys=ISBN"

  def find_by_isbn(isbn)
    response = HTTP.get("#{ISBN_LOOKUP_URL}:#{isbn}&format=json").to_s
    JSON.parse(response)["ISBN:#{isbn}"]
  end

  def lookup_attributes(lookup_info)
    url = lookup_info["info_url"].split("/")[0..-2].join("/") + ".json"
    response = HTTP.get(url).to_s
    parsed_response = JSON.parse(response)

    {
      title: parsed_response["title"],
      author: get_author(parsed_response["authors"], parsed_response["works"])
    }
  end

  def get_author(author_refs, work_refs)
    return try_getting_author_from_works(work_refs) if author_refs.nil? || author_refs.empty?
    author_refs.map { |ref| get_single_author(ref["key"]) }.join(", ")
  end

  def get_single_author(author_ref)
    full_url = "#{BASE_URL}#{author_ref}.json"
    response = HTTP.get(full_url).to_s
    JSON.parse(response)["name"]
  end

  def try_getting_author_from_works(work_refs)
    return "UNKNOWN" if work_refs.nil? || work_refs.empty?

    work_ref = work_refs.first["key"]
    full_url = "#{BASE_URL}#{work_ref}.json"
    response = HTTP.get(full_url).to_s
    author_refs = JSON.parse(response)["authors"].map { |a| { "key" => a["author"]["key"] } }

    get_author(author_refs, [])
  end

  def get_image_url(lookup_info)
    info_page = HTTP.get(lookup_info["info_url"]).to_s
    html = Nokogiri::HTML(info_page)
    image_tag = html.css('img.cover')[1]
    src_url = image_tag["src"]

    if src_url.starts_with?("//")
      "http:#{src_url}"
    else
      src_url
    end
  end
end
