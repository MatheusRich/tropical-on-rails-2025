require 'octokit'
require 'httparty'
require 'fileutils'
require 'thread'

# REPO = 'thoughtbot/gold_miner'
REPO = 'ruby/ruby'
OUTPUT_DIR = 'avatars'
MAX_THREADS = 1

FileUtils.mkdir_p(OUTPUT_DIR)

client = Octokit::Client.new
client.auto_paginate = true

contributors = client.contributors(REPO)
downloaded_count = 0
mutex = Mutex.new
BOT_USERS = ['[bot]', 'matzbot', 'step-security-bot']
# Divide contributors into chunks for each thread
thread_chunks = contributors.each_slice((contributors.size.to_f / MAX_THREADS).ceil).to_a

threads = []

thread_chunks.each do |chunk|
  threads << Thread.new(chunk) do |contributors_chunk|
    contributors_chunk.each do |contributor|
      avatar_url = contributor.avatar_url
      login = contributor.login
      next if BOT_USERS.include?(login)

      file_extension = File.extname(URI.parse(avatar_url).path)
      file_extension = file_extension.empty? ? '.png' : file_extension
      filename = File.join(OUTPUT_DIR, "#{login}#{file_extension}")

      next if File.exist?(filename)

      File.open(filename, 'wb') do |file|
        response = HTTParty.get(avatar_url)
        file.write(response.body)
      end

      mutex.synchronize { downloaded_count += 1 }
    end
  end
end

# Wait for all threads to complete
threads.each(&:join)

puts "Downloaded #{downloaded_count} new avatars to #{OUTPUT_DIR}/"
puts "Total contributors: #{contributors.count}"
