require "rails_helper"

RSpec.describe Task, type: :model do
  it { should belong_to(:user) }
  it { should have_one(:attachment).dependent(:destroy) }

  it { should validate_presence_of(:name) }
  it { should validate_inclusion_of(:state).in_array(%w(new started finished)) }

  it { should accept_nested_attributes_for(:attachment).allow_destroy(true) }

  it { should have_states :new, :started, :finished }
  it { should handle_events :start, when: :new }
  it { should handle_events :finish, when: :started }
  it { should reject_events :finish, when: :new }
  it { should reject_events :start, when: :finished }

  describe ".for_user" do
    let(:admin) { create(:user, role: "admin") }
    let(:user) { create(:user) }
    let!(:admin_tasks) { create_list(:task, 2, user: admin) }
    let!(:user_tasks) { create_list(:task, 2, user: user) }

    it "user get only assigned tasks" do
      expect(Task.for_user(user)).to match_array(user_tasks)
    end

    it "admin get all tasks" do
      expect(Task.for_user(admin)).to match_array(admin_tasks + user_tasks)
    end
  end

  describe "#assigned?" do
    let!(:user) { create(:user) }
    let!(:task) { create(:task) }

    it "should not task assigned to user" do
      expect(task.assigned?(user)).to be_falsey
    end

    it "should task assigned to user" do
      task.user = user
      expect(task.assigned?(user)).to be_truthy
    end
  end

  describe "#editable?" do
    let(:assigned_user) { create(:user) }
    let(:admin_user) { create(:user, role: "admin") }
    let(:another_user) { create(:user) }
    let(:task) { create(:task, user: assigned_user) }

    it "should return true for admin user" do
      expect(task.editable?(admin_user)).to be_truthy
    end

    it "should return true for assigned user" do
      expect(task.editable?(assigned_user)).to be_truthy
    end

    it "should return true for not assigned user" do
      expect(task.editable?(another_user)).to be_falsey
    end
  end

  describe "#change_state" do
    let(:admin_user) { create(:user, role: "admin") }
    let(:assigned_user) { create(:user) }
    let(:another_user) { create(:user) }
    let(:task) { create(:task, user: assigned_user) }

    context "as an assigned user" do
      it "can change state from new to started" do
        expect(task.change_state(assigned_user, "start")).to be_truthy
        expect(task.state).to eq("started")
      end

      it "can not change state from new to finished" do
        expect(task.change_state(assigned_user, "finish")).to be_falsey
        expect(task.state).to_not eq("finished")
      end
    end

    context "as an admin user" do
      it "can change state from new to started" do
        expect(task.change_state(admin_user, "start")).to be_truthy
        expect(task.state).to eq("started")
      end

      it "can not change state from new to finished" do
        expect(task.change_state(admin_user, "finish")).to be_falsey
        expect(task.state).to_not eq("finished")
      end
    end

    context "as an another user" do
      it "can not change state from new to started" do
        expect(task.change_state(another_user, "start")).to be_falsey
        expect(task.state).to_not eq("started")
      end

      it "can not change state from new to finished" do
        expect(task.change_state(another_user, "finish")).to be_falsey
        expect(task.state).to_not eq("finished")
      end
    end
  end
end
