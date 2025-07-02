# frozen_string_literal: true

module DiscourseKofi
  class AccountManagement
    def find_account(email)
      return nil unless email
      account = lookup_account(email)
      if account.nil?
        user = User.find_by_email(email)
        return nil unless user
        account = Account.new(email: email, user: user)
        account.save
        #TODO: notify user
      end
      account
    end

    def get_user_account(user, email)
      return nil unless user && email
      account = lookup_account(email)
      if account.nil?
        account = Account.new(email: email, user: user)
        account.save
        associate_with_unresolved_payments(account)
      else
        raise "Account registered to different user" if account.user != user
      end
      account
    end

    private

    def lookup_account(email)
      email = Email.downcase(email)
      email_hash = Account.hash_email(email)
      Account
        .where(email: email)
        .or(Account.where(email_hash: email_hash))
        .first
    end

    def associate_with_unresolved_payments(account)
      # This assumes the account has just been created, so there are no account settings to apply
      Payment.where(email: account.email, account: nil).update_all(
        account_id: account.id,
        user_id: account.user.nil? ? nil : account.user.id
      )
    end
  end
end
