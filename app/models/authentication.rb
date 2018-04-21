class Authentication < ActiveRecord::Base
  belongs_to :user

  after_create :accept_terms

  private

  # Social login has terms accepted implied
  def accept_terms
    user.update_attribute(:agree_terms, true)
  end
end