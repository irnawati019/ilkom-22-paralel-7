require 'mysql2'

class Database
  class << self
    attr_reader :db

    def setup
      return @db if @db && @db.ping

      retries = 0
      max_retries = 5

      begin
        puts "Mencoba koneksi ke database (percobaan #{retries + 1}/#{max_retries})..."
        
        @db = Mysql2::Client.new(
          host: ENV['DB_HOST'].to_s,
          username: ENV['DB_USER'] || 'whizzly',
          password: ENV['DB_PASSWORD'] || 'kelompok7',
          database: ENV['DB_NAME'] || 'whizzly_db',
          port: 3306,
          reconnect: true,
          connect_timeout: 10,
          read_timeout: 10,
          write_timeout: 10
        )

        puts "Koneksi ke database berhasil"

        # Create users table if not exists
        @db.query <<-SQL
          CREATE TABLE IF NOT EXISTS users (
            id INT AUTO_INCREMENT PRIMARY KEY,
            username VARCHAR(50) UNIQUE NOT NULL,
            email VARCHAR(100) UNIQUE NOT NULL,
            phone_number VARCHAR(15) UNIQUE,
            password_hash VARCHAR(255),
            oauth_provider VARCHAR(20),
            oauth_uid VARCHAR(100),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            status ENUM('aktif', 'nonaktif', 'banned') DEFAULT 'aktif'
          );
        SQL
        puts "Tabel 'users' telah dibuat atau sudah ada"
        @db

      rescue Mysql2::Error => e
        puts "Terjadi kesalahan saat menghubungkan ke database: #{e.message}"
        retries += 1
        if retries < max_retries
          sleep(2 ** retries)
          retry
        end
        nil
      end
    end

    def koneksi
      return @db if @db && @db.ping
      puts "Mencoba menginisialisasi koneksi database..."
      setup
    end

    def query(sql, params = nil)
      conn = koneksi
      return nil unless conn

      begin
        if params.nil?
          conn.query(sql, symbolize_keys: true)
        elsif params.is_a?(Array)
          stmt = conn.prepare(sql)
          result = stmt.execute(*params)
          stmt.close
          result
        else
          raise ArgumentError, "Parameters must be nil or Array"
        end
      rescue Mysql2::Error => e
        puts "Gagal menjalankan query: #{e.message}"
        raise e
      end
    end
  end
end