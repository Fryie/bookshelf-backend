class BookRequestsController < ApplicationController
  def create
    isbn = params["isbn"]

    lookup_info = find_by_isbn(isbn)
    book_attributes = lookup_attributes(lookup_info)
    all_attributes = book_attributes.merge(
      image_url: get_image_url(lookup_info),
      status: "requested"
    )

    book = Book.create!(all_attributes)

    render json: book
  rescue
    render json: {
      error: "Could not find information for ISBN #{params["isbn"]}"
    }
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
      author: get_author(parsed_response["authors"], parsed_response["works"]),
      isbn: parsed_response["isbn_13"][0]
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
