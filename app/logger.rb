class Logger
  def self.info(message)
    puts("#{Time.now.strftime("%H:%m:%S.%L")}: #{message}")
  end
end
