#!/usr/bin/env ruby

macro :textile do
	exact_parameters 1, :level => :warning
	rc = nil
	begin
		require 'RedCloth'
		rc = RedCloth.new @value, Glyph::CONFIG.get("filters.redcloth.restrictions")
	rescue Exception
		macro_error "RedCloth gem not installed. Please run: gem insall RedCloth"
	end
	target = Glyph["filters.target"]
	case target.to_sym
	when :html
		rc.to_html.gsub /<p><\/p>/, ''
	when :latex
		rc.to_latex
	else
		macro_error "RedCloth does not support target '#{target}'"
	end
end

macro :markdown do
	exact_parameters 1, :level => :warning
	md = nil
	markdown_converter = Glyph["filters.markdown_converter"].to_sym rescue nil
	if !markdown_converter then
		begin
			require 'bluecloth'
			markdown_converter = :bluecloth
		rescue LoadError
			begin 
				require 'rdiscount'
				markdown_converter = :rdiscount
			rescue LoadError
				begin 
					require 'maruku'
					markdown_converter = :maruku
				rescue LoadError
					begin 
						require 'kramdown'
						markdown_converter = :kramdown
					rescue LoadError
						macro_error "No MarkDown converter installed. Please run: gem install bluecloth"
					end
				end
			end
		end
		Glyph["filters.markdown_converter"] = markdown_converter
	end
	case markdown_converter
	when :bluecloth
		require 'bluecloth'
		md = BlueCloth.new @value
	when :rdiscount
		require 'rdiscount'
		md = RDiscount.new @value
	when :maruku
		require 'maruku'
		md = Maruku.new @value
	when :kramdown
		require 'kramdown'
		md = Kramdown::Document.new @value
	else
	 macro_error "No MarkDown converter installed. Please run: gem insall bluecloth"
	end
	target = Glyph["filters.target"]
	if target.to_sym == :html then
		md.to_html
	else
		macro_error "#{markdown_converter} does not support target '#{target}'"
	end
end

macro_alias :md => :markdown
