# frozen_string_literal: true

module Jekyll
  module TaxonomyFilters
    def sort_taxonomy_by_count(taxonomy)
      taxonomy.to_a.sort_by { |name, posts| [-posts.size, name.downcase] }
    end
  end

  Liquid::Template.register_filter(TaxonomyFilters)

  class CategoryPageGenerator < Generator
    safe true
    priority :low

    def generate(site)
      category_dir = site.config.fetch("category_dir", "category").sub(%r{^/|/$}, "")

      site.categories.each_key do |category|
        slug = Utils.slugify(category, mode: "default")
        site.pages << CategoryPage.new(site, category_dir, slug, category)
      end
    end
  end

  class CategoryPage < PageWithoutAFile
    def initialize(site, category_dir, slug, category)
      super(site, site.source, File.join(category_dir, slug), "index.html")

      self.data = {
        "layout" => "category",
        "title" => "#{category} 글",
        "category" => category,
        "category_slug" => slug,
        "permalink" => "/#{category_dir}/#{slug}/"
      }
    end
  end

  class TagPageGenerator < Generator
    safe true
    priority :low

    def generate(site)
      tag_dir = site.config.fetch("tag_dir", "tag").sub(%r{^/|/$}, "")

      site.tags.each_key do |tag|
        slug = Utils.slugify(tag, mode: "default")
        site.pages << TagPage.new(site, tag_dir, slug, tag)
      end
    end
  end

  class TagPage < PageWithoutAFile
    def initialize(site, tag_dir, slug, tag)
      super(site, site.source, File.join(tag_dir, slug), "index.html")

      self.data = {
        "layout" => "tag",
        "title" => "#{tag} 태그 글",
        "tag" => tag,
        "tag_slug" => slug,
        "permalink" => "/#{tag_dir}/#{slug}/"
      }
    end
  end

  class ArchivePageGenerator < Generator
    safe true
    priority :low

    def generate(site)
      site.posts.docs.group_by { |post| post.date.strftime("%Y") }.each do |year, posts|
        site.pages << ArchiveYearPage.new(site, year, posts)
      end
    end
  end

  class ArchiveYearPage < PageWithoutAFile
    def initialize(site, year, posts)
      super(site, site.source, File.join("archive", year), "index.html")

      self.data = {
        "layout" => "archive_year",
        "title" => "#{year}년 글",
        "year" => year,
        "posts" => posts,
        "permalink" => "/archive/#{year}/"
      }
    end
  end
end
