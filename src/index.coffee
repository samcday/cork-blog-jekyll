fs = require "fs"
path = require "path"
discount = require "discount"
yaml = require "yaml"

regex = 
	markdownFile: /(.*)\.(md|markdown)$/

class AnnexHandler
	constructor: (@annex) ->
	init: (files, cb) ->
		@files = files
		cb()
	processFile: (file, cb) ->
		self = @
		cb()

module.exports = (annex) ->
	return (new AnnexHandler annex)
