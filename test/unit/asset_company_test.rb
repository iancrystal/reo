require 'test_helper'

class AssetCompanyTest < ActiveSupport::TestCase

  #fixtures :asset_companies

  test "invalid with empty attributes" do
    company = AssetCompany.new
    assert !company.valid?
    assert company.errors.invalid?(:email)
  end

  test "unique email" do
    company = AssetCompany.new(:email => asset_companies(:juan).email)
    assert !company.save
    assert_equal I18n.translate('activerecord.errors.messages.taken' ),
      company.errors.on(:email)
  end

end

