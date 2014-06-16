require 'thor'
class Release < Thor

  DIR = "release_notes"
  method_option :since, type: :string, desc: "since commit_ref", required: true, aliases: 's'
  method_option :edit, type: :boolean, desc: "edit", required: false, aliases: 'e'

  desc "prepare -s SINCE_COMMIT_REF VERSION", <<-END
    Prepare for release by listing commits since SINCE_COMMIT_REF ready for use  and creating in a release page.
Works well if the SINCE_COMMIT_REF is a git tag and the VERSION is the next tag.
END

  def prepare(to_commit_ref)
    since_commit_ref = options[:since]
    headers = [
        "##{to_commit_ref} Release Notes",
        "",
        "*Changes since ##{since_commit_ref}*",
        "",
    ].join("\n")
    puts headers
    commits = `git log #{since_commit_ref}..HEAD --pretty=format:"- %B"`
    notes = commits.gsub("\n\n", "\n")
    notes_file = "#{DIR}/#{to_commit_ref}.md"
    if File.exists?(notes_file)
      puts "-"*80
      puts " File '#{notes_file}' already exists"
      puts "-"*80
      puts notes
    else
      Dir.mkdir(DIR) unless File.exists?(DIR)
      File.open(notes_file, 'w') do |f|
        f.puts(headers)
        f.puts(notes)
      end
      puts "written to #{notes_file}"
      if options[:edit]
        system("open #{notes_file}")
      end
    end

  end

end