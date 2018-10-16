class Book < ApplicationRecord
  VALID_STATUS = %w(requested available borrowed)
end
