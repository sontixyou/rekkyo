# frozen_string_literal: true

module Rekki
  class Core
    def self.generate_files_name
      files_path = []
      Dir.glob('./**/*') do |path|
        next if FileTest.directory?(path)	# ディレクトリは無視

        files_path << path
      end
      files_path
    end

    def self.select_image_files(files_path)
      return 'Image files count is 0' if files_path.nil?

      select_image_files = files_path.select do |file|
        if file.include?('.webp') || file.include?('.jpeg') || file.include?('.jpg') || file.include?('.png') || file.include?('.svg')
          file.gsub!(%r{.[/0-9a-zA-Z_-]+/}, '')
        end
      end
      return 'Image files count is 0' if select_image_files.count.zero? || select_image_files.nil?

      select_image_files
    end

    def self.select_view_files_path(files_path)
      return 'View files and Ruby files count is 0' if files_path.nil?

      view_files_path = files_path.select do |file_path|
        file_path.include?('.html.haml') || file_path.include?('.slim') || file_path.include?('.erb')
      end
      return 'View files and Ruby files count is 0' if view_files_path.count.zero? || view_files_path.nil?

      view_files_path
    end

    def self.count_images_in_view_file
      # select_view_files_and_ruby_filesからの返り値を使用して、それぞれのファイルでgrepを行う。
      # select_image_filesの画像がヒットするかを判別する。
      # ヒットした画像のパスが何回登場したのかを配列に持たせる。
      # できれば、それをグラフ化したい。簡易的ならこんな感じ
      # kojo: ********
      # aoki: ****
      start_time = Time.now
      puts "start time: #{start_time}"
      files_name = generate_files_name
      view_files_path = select_view_files_path(files_name)
      puts views_files_path and return if view_files_path.class != Array

      image_files_name = select_image_files(files_name)
      puts image_files_name and return if image_files_name.class != Array
      # binding.break

      result = {}

      image_files_name.each do |image|
        image_count = 0
        view_files_path.each do |file_path|
          command = "rg \"#{image}\" #{file_path}"

          stdout, stderr, status = Open3.capture3(command)
          image_count += stdout.split("\n").count
        end
        result = { image => image_count }
      end

      puts 'IMAGE COUNT RESULT'
      result.each do |k, v|
        puts "#{k}: #{'*' * v}"
      end
      puts "end time: #{Time.now - start_time}"
    end
  end
end