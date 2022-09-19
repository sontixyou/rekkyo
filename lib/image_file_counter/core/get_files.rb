# frozen_string_literal: true

module ImageFileCounter
  class Core
    def self.generate_files_name
      file_name_array = []
      Dir.glob('./**/*') do |path|
        next if FileTest.directory?(path)	# ディレクトリは無視

        file_name_array << path
      end
      file_name_array
    end

    def self.select_image_files(files_path)
      return ['nothings'] if files_path.nil?

      select_image_files = files_path.select do |file|
        if file.include?('.jpeg') || file.include?('.jpg') || file.include?('.png') || file.include?('.svg')
          file.gsub!(/.[\/0-9a-zA-Z_-]+\/image\//, '')
        end
      end
      return 'Image files count is 0' if select_image_files.count.zero?

      select_image_files
    end

    def self.select_view_files_and_ruby_files(files_path)
      return [] if files_path.nil?

      view_files_and_rb_files = files_path.select do |file|
        file.include?('.rb') || file.include?('.html.haml') || file.include?('.slim') || file.include?('.erb')
      end
      return 'View files and Ruby files count is 0' if view_files_and_rb_files.count.zero?

      view_files_and_rb_files.map do |file|
        puts file
      end
      view_files_and_rb_files
    end

    def self.count_images_in_view_file
      # select_view_files_and_ruby_filesからの返り値を使用して、それぞれのファイルでgrepを行う。
      # select_image_filesの画像がヒットするかを判別する。
      # ヒットした画像のパスが何回登場したのかを配列に持たせる。
      # できれば、それをグラフ化したい。簡易的ならこんな感じ
      # kojo: ********
      # aoki: ****
      files_name = generate_files_name
      view_files_path = select_view_files_and_ruby_files(files_name)
      imags_file_name = select_image_files(files_name)
      result = {}

      return puts "files_path is nil" if view_files_path.nil? || imags_file_name.nil?

      imags_file_name.each do |image|
        image_count = 0
        view_files_path.each do |file_path|
          command = "rg \"#{image}\" #{file_path}"
          puts command
          stdout, stderr, status = Open3.capture3(command)
          image_count += stdout.split("\n").count
          puts image_count
        end
        result = { image => image_count }
      end

      result.each do |k,v|
        puts "#{k} : #{v}回使用されています"
      end
    end
  end
end
