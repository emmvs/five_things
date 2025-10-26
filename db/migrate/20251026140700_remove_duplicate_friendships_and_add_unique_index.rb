class RemoveDuplicateFriendshipsAndAddUniqueIndex < ActiveRecord::Migration[8.0]
  def up
    # Remove bidirectional duplicates - keep only one direction per friendship
    # For each pair of users, keep the friendship with the lower ID
    execute <<-SQL
      DELETE FROM friendships
      WHERE id IN (
        SELECT f2.id
        FROM friendships f1
        INNER JOIN friendships f2 ON f1.user_id = f2.friend_id AND f1.friend_id = f2.user_id
        WHERE f1.id < f2.id
      )
    SQL
    
    # Note: Unique index already exists in schema
    # index_friendships_on_user_id_and_friend_id is already present
  end

  def down
    # Duplicates were removed, can't be restored
    # Index already existed, won't be removed
  end
end
