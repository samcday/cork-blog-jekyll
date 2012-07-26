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
		@annex.addFileHandler /\.(md|markdown)$/, @processPost
		return cb()
		###
		self = @
		@files = files
		async.forEach @files, (file, cb) ->
			return cb() unless matches = regex.blogPost.exec file
			
			
				return cb err if err
				
				date = matter.date or date
				self.annex.addPost slug, matter.title or title, date, matter.categories, matter.tags
				cb()
		, cb
		###
	processPost: (file, cb) =>
		self = @
		return cb() unless matches = regex.blogPost.exec file
		[fileDate, slug] = matches[1..]
		fs.readFile (@annex.pathTo file), "utf8", (err, data) ->
			[meta, content] = self._parsePostData data
			meta.date = new Date fileDate unless meta.date
			self.annex.blog.addPost slug, meta.title, meta.date, content, meta.categories, meta.tags
			cb()
	_parsePostData: (data) ->
		return null unless data[0...4] is "---\n"
		return null unless (end = data.indexOf "---\n", 1) > 0

		# Parse out and process the YAML front matter at the top first.
		frontMatter = yaml.load data.substring 4, end - 1
		meta = @_processFrontMatter frontMatter

		# And now the post content that follows.
		content = discount.parse data.substring end + 4

		return [meta, content]
	_processFrontMatter: (frontMatter) ->
		meta = {}
		meta.title = frontMatter.title
		meta.date = (new Date frontMatter.date) if frontMatter.date
		meta.layout = frontMatter.layout if frontMatter.layout
		meta.published = frontMatter.published if frontMatter.published
		if frontMatter.category
			meta.categories = [frontMatter.category] if frontMatter.category
		else if frontMatter.categories
			{categories} = frontMatter
			categories = categories.split " " if "string" is typeof categories
			meta.categories = categories
		if frontMatter.tags
			{tags} = frontMatter
			tags = tags.split " " if "string" is typeof tags
			meta.tags = tags
		return meta

module.exports = (annex) ->
	return (new AnnexHandler annex)
