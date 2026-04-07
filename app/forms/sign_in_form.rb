# frozen_string_literal: true

class SignInForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :username, :string
  attribute :password, :string

  validates :username, presence: true
  validates :password, presence: true
end
