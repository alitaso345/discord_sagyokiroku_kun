require 'sqlite3'

db = SQLite3::Database.new('test.db')
db.execute <<-SQL
  create table activity_logs (
    id integer primary key,
    user_id text not null,
    start_at text not null,
    end_at text
  );

  create index user_id_index on activity_logs(user_id);
SQL