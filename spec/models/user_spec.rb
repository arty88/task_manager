require "rails_helper"

RSpec.describe User, type: :model do
  it { should have_many(:tasks).dependent(:destroy) }

  it do
    subject.password = "pass123"
    should validate_uniqueness_of(:email)
  end
  it { should validate_presence_of(:password) }
  it { should validate_length_of(:password).is_at_least(6) }
  it { should validate_confirmation_of(:password) }
  it { should validate_inclusion_of(:role).in_array(%w(admin user)) }

  it "validates that email correct format" do
    user = build(:user, email: "incorrect_format_email")
    user.valid?

    expect(user.errors[:email]).to eq(["is incorrect format"])
  end

  describe "encrypt password" do
    subject { build(:user) }

    it "should encrypt password before create user" do
      expect(subject).to receive(:set_encrypt_password)
      subject.save!
    end

    it "should not encrypt password before update user" do
      subject.save!
      expect(subject).to_not receive(:set_encrypt_password)
      subject.update(password: "321pass")
    end

    it "should encrypt password" do
      password = subject.password
      subject.save!
      expect(subject.password).to_not eq(password)
    end
  end

  describe "#authenticate" do
    let(:user) { create(:user) }

    it "return user when right password" do
      expect(user.authenticate("pass123")).to eq(user)
    end

    it "return False when password wrong" do
      expect(user.authenticate("wrong_pass")).to be_falsey
    end
  end

  describe "#to_s" do
    let(:user) { create(:user) }

    it "return email" do
      expect(user.to_s).to eq(user.email)
    end
  end

  describe "#admin?" do
    let(:user) { create(:user) }
    let(:admin_user) { create(:user, role: "admin") }

    it "return true" do
      expect(admin_user.admin?).to be_truthy
    end

    it "return false" do
      expect(user.admin?).to be_falsey
    end
  end
end
