# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

gemspec

gem "gem_report", git: "http://github.com/ideacrew/gem_report.git", branch: "trunk"

group :dev, :test do
  gem "rspec"
end
