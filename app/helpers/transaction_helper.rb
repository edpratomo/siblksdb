module TransactionHelper
  def transaction_user username, &blk
    quoted_username = ActiveRecord::Base.connection.quote(username)
    transaction do
      ActiveRecord::Base.connection.execute('CREATE TEMPORARY TABLE current_app_user(username TEXT) ON COMMIT DROP')
      ActiveRecord::Base.connection.execute("INSERT INTO current_app_user VALUES('#{quoted_username}')")
      blk.call
    end
  end
end
