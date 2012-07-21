fs = require "fs"
async = require "async"
path = require "path"
discount = require "discount"
yaml = require "js-yaml"

regex = 
	blogPost: /^([0-9]{4}-[0-9]{2}-[0-9]{2})-(.*?)\.(md|markdown)$/

class AnnexHandler
	constructor: (@annex) ->
	init: (files, cb) ->
		self = @
		@files = files
		async.forEach @files, (file, cb) ->
			return cb() unless matches = regex.blogPost.exec file
			[date, slug] = matches[1..]
			date = new Date date
			fs.readFile (self.annex.pathTo file), "utf8", (err, data) ->
				return cb err if err
				matter = self.parseFrontMatter data
				date = matter.date or date
				self.annex.addPost slug, matter.title or title, date, matter.categories, matter.tags
				cb()
		, cb
	processFile: (file, cb) ->
		self = @
		return unless matches = regex.blogPost.exec file
		fs.readFile (@annex.pathTo file), "utf8", (err, data) ->
			return cb err if err?
			[date, slug] = matches[1..]
			content = data.substring (data.indexOf "---\n", 1) + 4
			blogContent = discount.parse content
			{date} = metadata = self.annex.getPost slug
			layout = self.annex.config.layout
			outName = "#{date.getFullYear()}/#{date.getMonth()+1}/#{date.getDate()}/#{slug}/index.html"
			self.annex.writePost slug, outName, layout, blogContent, cb
	parseFrontMatter: (data) ->
		return null unless (data.indexOf "---\n") is 0
		return null unless (end = data.indexOf "---\n", 1) > 0
		raw = data.substring 4, end - 1
		frontMatter = yaml.load raw
		frontMatter.date = (new Date frontMatter.date) if frontMatter.date
		return frontMatter

module.exports = (annex) ->
	return (new AnnexHandler annex)
