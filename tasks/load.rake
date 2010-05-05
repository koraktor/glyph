#!/usr/bin/env ruby

namespace :load do

	desc "Load all files"
	task :all => [:bibliography, :config, :snippets, :macros] do
	end

	desc 'Load bibliography'
	task :bibliography do
		unless Glyph.lite?
			raise RuntimeError, "The current directory is not a valid Glyph project" unless Glyph.project?
			Glyph.info 'Loading bibliography entries...'
			bibliography = yaml_load Glyph::PROJECT/'bibliography.yml'
			raise RuntimeError, "Invalid bibliography file" unless bibliography.blank? || bibliography.is_a?(Hash)
			Glyph::BIBLIOGRAPHY.replace bibliography
		end
	end

	desc "Load snippets"
	task :snippets do
		unless Glyph.lite? then
			raise RuntimeError, "The current directory is not a valid Glyph project" unless Glyph.project?
			Glyph.info "Loading snippets..."
			snippets = yaml_load Glyph::PROJECT/'snippets.yml'
			raise RuntimeError, "Invalid snippets file" unless snippets.blank? || snippets.is_a?(Hash)
			Glyph::SNIPPETS.replace snippets
		end
	end

	desc "Load macros"
	task :macros do
		raise RuntimeError, "The current directory is not a valid Glyph project" unless Glyph.project? || Glyph.lite?
		Glyph.info "Loading macros..."
		load_macros = lambda do |macro_base|
			macro_base.children.each do |c|
				Glyph.instance_eval file_load(c) unless c.directory?
			end
			macro_dir = macro_base/Glyph["filters.target"].to_s
			if macro_dir.exist? then
				macro_dir.children.each do |f|
					Glyph.instance_eval file_load(f) unless f.directory?
				end
			end
			bibstyle_macros = macro_base/Glyph['filters.target']/'bibstyles'/(Glyph['document.bibstyle'] + '.rb')
			if bibstyle_macros.exist?
				Glyph.instance_eval file_load(bibstyle_macros)
			end
		end
		load_macros.call Glyph::HOME/"macros"
		unless Glyph.lite? then
			load_macros.call Glyph::PROJECT/"lib/macros" rescue nil
		end
	end

	desc "Load configuration files"
	task :config do
		raise RuntimeError, "The current directory is not a valid Glyph project" unless Glyph.project? || Glyph.lite?
		# Save overrides set by commands...
		overrides = Glyph::PROJECT_CONFIG.dup
		Glyph::PROJECT_CONFIG.read unless Glyph.lite?
		Glyph::PROJECT_CONFIG.merge! overrides
		Glyph::SYSTEM_CONFIG.read
		Glyph::GLOBAL_CONFIG.read
        Glyph.config_refresh
		Glyph["structure.headers"] = [:section] +
													Glyph['structure.frontmatter'] + 
													Glyph['structure.backmatter'] + 
													Glyph['structure.bodymatter'] - 
													Glyph['structure.hidden']
	end

end
