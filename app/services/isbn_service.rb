class ISBNService
  InvalidISBNError = Class.new StandardError
  BookNotFoundError = Class.new StandardError
  InvalidApiResponseError = Class.new StandardError

  class << self
    def lookup(isbn13)
      meta_info = find_meta_info_by_isbn(isbn13)
      book_attributes = lookup_attributes(meta_info)

      book_attributes.merge(
        isbn: isbn13,
        image_url: get_image_url(meta_info)
      )
    end

    def validate_and_convert_isbn(isbn)
      ISBN.valid?(isbn) || raise(InvalidISBNError)
      ISBN.thirteen(isbn) # convert to ISBN-13, in case ISBN-10 was passed
    end

    private

    BASE_URL = "https://openlibrary.org"
    ISBN_LOOKUP_URL = "#{BASE_URL}/api/books?bibkeys=ISBN"

    def find_meta_info_by_isbn(isbn)
      begin
        response = HTTP.get("#{ISBN_LOOKUP_URL}:#{isbn}&format=json").to_s
        parsed_response = JSON.parse(response)
      rescue
        raise InvalidApiResponseError
      end

      meta_info = parsed_response["ISBN:#{isbn}"]
      meta_info.presence || raise(BookNotFoundError)
    end

    def lookup_attributes(meta_info)
      begin
        url = meta_info["info_url"].split("/")[0..-2].join("/") + ".json"
        response = HTTP.get(url).to_s
        parsed_response = JSON.parse(response)
      rescue
        raise InvalidApiResponseError
      end

      title = parsed_response["title"].presence || raise(InvalidApiResponseError)
      author = get_author(parsed_response["authors"], parsed_response["works"])

      {
        title: title,
        author: author
      }
    end

    def get_author(author_refs, work_refs)
      return try_getting_author_from_works(work_refs) if author_refs.nil? || author_refs.empty?
      author_refs.map { |ref| get_single_author(ref["key"]) }.join(", ")
    end

    def get_single_author(author_ref)
      full_url = "#{BASE_URL}#{author_ref}.json"
      response = HTTP.get(full_url).to_s
      JSON.parse(response)["name"].presence || raise(InvalidApiResponseError)
    rescue
      raise InvalidApiResponseError
    end

    def try_getting_author_from_works(work_refs)
      return "UNKNOWN" if work_refs.nil? || work_refs.empty?

      work_ref = work_refs.first["key"]
      full_url = "#{BASE_URL}#{work_ref}.json"
      response = HTTP.get(full_url).to_s
      author_refs = JSON.parse(response)["authors"].map { |a| { "key" => a["author"]["key"] } }

      get_author(author_refs, [])
    rescue
      raise InvalidApiResponseError
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
    rescue
      "" # if there is a problem, just return empty image URL
    end

  end
end
