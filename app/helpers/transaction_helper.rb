module TransactionHelper
  # sanitize?
  def transaction_user username, &blk
    transaction do
      ActiveRecord::Base.connection.execute('CREATE TEMPORARY TABLE current_app_user(username TEXT) ON COMMIT DROP')
      ActiveRecord::Base.connection.execute("INSERT INTO current_app_user VALUES('#{username}')")
      blk.call
    end
  end
end
