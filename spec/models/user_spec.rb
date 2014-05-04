require 'spec_helper'

describe User do

  before  { @User = User.new(name: "Example User", email: "example@example.com", password: 'foobar', password_confirmation: 'foobar') }

  subject { @User }

  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:remember_token) }
  it { should respond_to(:authenticate) }

  describe 'when name is not present' do
    it 'should not be vaild' do
      @User.name = ''
      expect(@User.valid?).to eq(false)
    end
  end

  describe 'when email is not present' do
    it 'should not be vaild' do
      @User.email = ''
      expect(@User.valid?).to eq(false)
    end
  end

  describe 'when name is too long' do
    it 'should not be valid' do
      @User.name = 'a' * 51
      expect(@User.valid?).to eq(false)
    end
  end

  describe "when email format is invalid" do
    it "should be invalid" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                     foo@bar_baz.com foo@bar+baz.com]
                     addresses.each do |invalid_address|
                       @User.email = invalid_address
                       expect(@User).not_to be_valid
                     end
    end
  end

  describe "when email format is valid" do
    it "should be valid" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        @User.email = valid_address
        expect(@User).to be_valid
      end
    end
  end

  describe "when email address is already taken" do
    before do
      user_with_same_email = @User.dup
      user_with_same_email.email.upcase
      user_with_same_email.save
    end

    it { should_not be_valid }
  end

  describe "when password is not present" do
    before do
      @User = User.new(name: "Example User", email: "user@example.com",
                       password: " ", password_confirmation: " ")
    end
    it { should_not be_valid }
  end

  describe "when password does not match confirmation" do
    before do
      @User.password_confirmation = 'bar'
    end
    it { should_not be_valid }
  end

  describe "with a password that's too short" do
    before { @User.password = @User.password_confirmation = "a" * 5 }
    it { should be_invalid }
  end

  describe "return value of authenticate method" do
    before { @User.save }
    let(:found_user) { User.find_by_email(@User.email)}

    describe "with valid password" do
      it { should eq found_user.authenticate(@User.password) }
    end

    describe "with invalid password" do
      let(:invalid_user) { found_user.authenticate("invalid") }

      it { should_not eq invalid_user }
      specify { expect(invalid_user).to be_false }
    end
  end

  describe "remember token" do
    before { @User.save }
    its(:remember_token) { should_not be_blank }
  end
end
